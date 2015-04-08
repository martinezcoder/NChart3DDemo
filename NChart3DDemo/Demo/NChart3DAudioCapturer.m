/**
 * Disclaimer: IMPORTANT:  This Nulana software is supplied to you by Nulana
 * LTD ("Nulana") in consideration of your agreement to the following
 * terms, and your use, installation, modification or redistribution of
 * this Nulana software constitutes acceptance of these terms.  If you do
 * not agree with these terms, please do not use, install, modify or
 * redistribute this Nulana software.
 *
 * In consideration of your agreement to abide by the following terms, and
 * subject to these terms, Nulana grants you a personal, non-exclusive
 * license, under Nulana's copyrights in this original Nulana software (the
 * "Nulana Software"), to use, reproduce, modify and redistribute the Nulana
 * Software, with or without modifications, in source and/or binary forms;
 * provided that if you redistribute the Nulana Software in its entirety and
 * without modifications, you must retain this notice and the following
 * text and disclaimers in all such redistributions of the Nulana Software.
 * Except as expressly stated in this notice, no other rights or licenses, 
 * express or implied, are granted by Nulana herein, including but not limited 
 * to any patent rights that may be infringed by your derivative works or by other
 * works in which the Nulana Software may be incorporated.
 *
 * The Nulana Software is provided by Nulana on an "AS IS" basis.  NULANA
 * MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 * THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE, REGARDING THE NULANA SOFTWARE OR ITS USE AND
 * OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 *
 * IN NO EVENT SHALL NULANA BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 * MODIFICATION AND/OR DISTRIBUTION OF THE NULANA SOFTWARE, HOWEVER CAUSED
 * AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 * STRICT LIABILITY OR OTHERWISE, EVEN IF NULANA HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (C) 2015 Nulana LTD. All Rights Reserved.
 */
 

#import "NChart3DAudioCapturer.h"

#define SAMPLE_RATE 44100
#define QUEUE_SIZE  8
#define FRAME_RATE  (1.0 / 30.0)


@implementation NChart3DAudioCapturer
{
    AVCaptureSession *m_captureSession;
	AVCaptureDevice *m_captureDevice;
    float **m_audioSpectrumBuffers;
    float *m_dftR;
    float *m_dftI;
    float *m_spectrum;
    float *m_spectrumToSend;
    vDSP_DFT_Setup m_dftSetup;
    size_t m_bufferCursor;
    size_t m_bufferID;
    dispatch_queue_t m_frameDroppingQueue;
    dispatch_semaphore_t m_frameDroppingSem;
    NSInteger m_countOfSpectra;
    NSInteger m_spectrumSize;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        m_audioSpectrumBuffers = (float **)malloc(QUEUE_SIZE * sizeof(float *));
        for (int i = 0; i < QUEUE_SIZE; ++i)
            m_audioSpectrumBuffers[i] = NULL;
    }
    return self;
}

- (void)dealloc
{
    [self killDevice];
    
    if (m_spectrumSize > 0)
    {
        for (int i = 0; i < QUEUE_SIZE; ++i)
            free(m_audioSpectrumBuffers[i]);
        free(m_dftR);
        free(m_dftI);
        free(m_spectrum);
        free(m_spectrumToSend);
        vDSP_DFT_DestroySetup(m_dftSetup);
    }
    if (m_audioSpectrumBuffers)
        free(m_audioSpectrumBuffers);
    
    [super dealloc];
}

- (BOOL)initDevice
{
    // Stop previous session if any
    [self stopCaptureSession];
    
    // Create session
    m_captureSession = [AVCaptureSession new];
    m_captureSession.sessionPreset = AVCaptureSessionPresetHigh;
	
    // Find device
    m_captureDevice = nil;
    for (AVCaptureDevice *device in AVCaptureDevice.devices)
    {
        if ([device hasMediaType:AVMediaTypeAudio])
        {
            m_captureDevice = device;
            [m_captureDevice retain];
            break;
        }
    }
    if (!m_captureDevice)
    {
        [m_captureSession release], m_captureSession = nil;
        NSLog(@"NChart3DAudioCapturer error: no microphone found");
        return NO;
    }
	
    // Add device to a session
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:m_captureDevice error:&error];
    if (!input)
    {
        [m_captureDevice release], m_captureDevice = nil;
        [m_captureSession release], m_captureSession = nil;
        NSLog(@"NChart3DAudioCapturer error: error while creating input device, terminating");
        return NO;
    }
    [m_captureSession addInput:input];
    
    // Create audio output.
    AVCaptureAudioDataOutput *output = [[AVCaptureAudioDataOutput new] autorelease];
    [m_captureSession addOutput:output];
    dispatch_queue_t queue = dispatch_queue_create("NChart3DAudioCapturer", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    m_frameDroppingQueue = dispatch_queue_create("NChart3DAudioCapturer::FrameDropper", NULL);
    m_frameDroppingSem = dispatch_semaphore_create(0);
    
    return YES;
}

- (void)killDevice
{
    [self stopCaptureSession];
    
    [m_captureSession release], m_captureSession = nil;
    [m_captureDevice release], m_captureDevice = nil;
    
    if (m_frameDroppingQueue)
    {
        dispatch_release(m_frameDroppingQueue), m_frameDroppingQueue = NULL;
        dispatch_release(m_frameDroppingSem), m_frameDroppingSem = NULL;
    }
}

- (void)startCaptureSession
{
    if (m_frameDroppingSem && !m_captureSession.isRunning)
    {
        m_bufferCursor = 0;
        m_bufferID = 0;
        dispatch_semaphore_signal(m_frameDroppingSem);
        [m_captureSession startRunning];
    }
}

- (void)stopCaptureSession
{
    if (m_frameDroppingSem && m_captureSession.isRunning)
    {
        [m_captureSession stopRunning];
        dispatch_semaphore_wait(m_frameDroppingSem, DISPATCH_TIME_FOREVER);
    }
}

- (BOOL)isInited
{
    return m_captureSession != nil;
}

- (NSInteger)spectrumSize
{
    return m_spectrumSize;
}

- (NSInteger)clampSpectrumSize:(NSInteger)size
{
    const NSInteger availableSizes[11] =
    {
        3 * 32,
        5 * 32,
        3 * 64,
        5 * 64,
        3 * 128,
        5 * 128,
        3 * 256,
        5 * 256,
        3 * 512,
        5 * 512,
        3 * 1024
    };
    for (int i = 0; i < 10; ++i)
    {
        if (availableSizes[i + 1] > size)
            return availableSizes[i];
    }
    return availableSizes[10];
}

- (void)setSpectrumSize:(NSInteger)spectrumSize
{
    @synchronized(self)
    {
        if (m_spectrumSize > 0)
        {
            for (int i = 0; i < QUEUE_SIZE; ++i)
                free(m_audioSpectrumBuffers[i]);
            free(m_dftR);
            free(m_dftI);
            free(m_spectrum);
            free(m_spectrumToSend);
            vDSP_DFT_DestroySetup(m_dftSetup);
        }
        
        m_spectrumSize = [self clampSpectrumSize:spectrumSize];
        
        if (m_spectrumSize > 0)
        {
            for (int i = 0; i < QUEUE_SIZE; ++i)
            {
                m_audioSpectrumBuffers[i] = (float *)malloc(m_spectrumSize * sizeof(float));
                memset(m_audioSpectrumBuffers[i], 0, m_spectrumSize * sizeof(float));
            }
            m_dftR = (float *)malloc(m_spectrumSize / 2 * sizeof(float));
            m_dftI = (float *)malloc(m_spectrumSize / 2 * sizeof(float));
            m_spectrum = (float *)malloc(m_spectrumSize / 2 * sizeof(float));
            memset(m_spectrum, 0, m_spectrumSize / 2 * sizeof(float));
            m_spectrumToSend = (float *)malloc(m_spectrumSize / 2 * sizeof(float));
            m_dftSetup = vDSP_DFT_zrop_CreateSetup(NULL, m_spectrumSize, kFFTDirection_Forward);
            m_bufferCursor = 0;
        }
    }
}

- (NSInteger)sampleRate
{
    return SAMPLE_RATE;
}

- (void)processSpectrum
{
    for (int i = 0, j = 0; i < m_spectrumSize / 2; ++i, j += 2)
    {
        m_dftR[i] = 0.0f;
        m_dftI[i] = 0.0f;
        for (int k = 0; k < QUEUE_SIZE; ++k)
        {
            m_dftR[i] += m_audioSpectrumBuffers[k][j];
            m_dftI[i] += m_audioSpectrumBuffers[k][j + 1];
        }
        m_dftR[i] /= (float)QUEUE_SIZE;
        m_dftI[i] /= (float)QUEUE_SIZE;
    }
    
    vDSP_DFT_Execute(m_dftSetup, m_dftR, m_dftI, m_dftR, m_dftI);
    
    m_spectrum[0] = 0.0f;
    for (int i = 1; i < m_spectrumSize / 2; ++i)
        m_spectrum[i] += hypotf(m_dftR[i] / (float)m_spectrumSize, m_dftI[i] / (float)m_spectrumSize);
    
    ++m_countOfSpectra;
    
    if (dispatch_semaphore_wait(m_frameDroppingSem,  DISPATCH_TIME_NOW) == 0)
    {
        memcpy(m_spectrumToSend, m_spectrum, m_spectrumSize / 2 * sizeof(float));
        memset(m_spectrum, 0, m_spectrumSize / 2 * sizeof(float));
        for (int i = 0; i < m_spectrumSize / 2; ++i)
            m_spectrumToSend[i] /= (float)m_countOfSpectra;
        m_countOfSpectra = 0;
        dispatch_async(m_frameDroppingQueue,
                       ^(void)
                       {
                           NSTimeInterval timeStart = [NSDate timeIntervalSinceReferenceDate];
                           [self.delegate audioCapturerSpectrumData:m_spectrumToSend withFFTSize:m_spectrumSize / 2];
                           NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate] - timeStart;
                           if (time < FRAME_RATE)
                               [NSThread sleepForTimeInterval:FRAME_RATE - time];
                           dispatch_semaphore_signal(m_frameDroppingSem);
                       });
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @synchronized(self)
    {
        size_t length;
        short *data;
        CMBlockBufferRef block = CMSampleBufferGetDataBuffer(sampleBuffer);
        CMBlockBufferGetDataPointer(block, 0, NULL, &length, (char **)(&data));
        length /= sizeof(short);
        
        for (size_t i = 0; i < length; ++i)
        {
            if (m_bufferCursor == m_spectrumSize)
            {
                [self processSpectrum];
                m_bufferCursor = 0;
                ++m_bufferID;
                if (m_bufferID == QUEUE_SIZE)
                    m_bufferID = 0;
            }
            else
            {
                m_audioSpectrumBuffers[m_bufferID][m_bufferCursor++] = (float)(data[i]) / 32768.0f;
            }
        }
        
        [self processSpectrum];
        
        if (m_bufferCursor == m_spectrumSize)
        {
            m_bufferCursor = 0;
            ++m_bufferID;
            if (m_bufferID == QUEUE_SIZE)
                m_bufferID = 0;
        }
    }
}

@end
