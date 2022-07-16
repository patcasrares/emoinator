#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/objdetect.hpp>

using namespace std;
using namespace cv;

#define C_API extern "C" __attribute__((visibility("default"))) __attribute__((used))

cv::CascadeClassifier cascade;
std::vector<Rect> detectedObjects;
cv::Mat yuv;
cv::Mat bgr;

void (*logger)(const char*) = NULL;
void log(const char* string)
{
    if (logger != NULL)
        logger(string);
}

C_API uint32_t* initDetection(void (*logCallback)(const char*), const char* filename)
{
    logger = logCallback;
    if (!cascade.load(filename))
        log("Couldn't load classifier from the given filename\n");
    log("Classifier loaded!\n");
    return NULL;
}

// noFaces is an output parameter; the returned buffer contains 4 * noFaces values (x, y, width, height)
C_API uint32_t* detectFaces(uint32_t* ABGR, int width, int height, uint32_t* noFaces)
{
    if (cascade.empty())
    {
        log("Classifier not loaded!\n");
        return NULL;
    }
    
    detectedObjects.clear();

    Mat abgr(height, width, CV_8UC4, ABGR);
    Mat bgr(height, width, CV_8UC3);
    Mat gray(height, width, CV_8UC1);

    mixChannels(abgr, bgr, {1,0, 2,1, 3,2});
    cvtColor(bgr, gray, COLOR_BGR2GRAY);
    equalizeHist(gray, gray);

    cascade.detectMultiScale(gray, detectedObjects);

    uint32_t* result = new uint32_t[4 * detectedObjects.size()];
    for (int i = 0; i < detectedObjects.size(); ++i) {
        result[i * 4] = detectedObjects[i].x;
        result[i * 4 + 1] = detectedObjects[i].y;
        result[i * 4 + 2] = detectedObjects[i].width;
        result[i * 4 + 3] = detectedObjects[i].height;
    }
    *noFaces = (uint32_t)detectedObjects.size();
    return result;
}

C_API uint32_t* freeBuffer(uint32_t* buffer) 
{
    delete[] buffer;
    return NULL;
}