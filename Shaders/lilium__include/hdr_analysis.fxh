#pragma once

#include "colour_space.fxh"


#if defined(IS_HDR_COMPATIBLE_API)

//max is 32
//#ifndef THREAD_SIZE0
  #define THREAD_SIZE0 8
//#endif

//max is 1024
//#ifndef THREAD_SIZE1
  #define THREAD_SIZE1 8
//#endif

//#if (BUFFER_WIDTH % THREAD_SIZE0 == 0)
#if (BUFFER_WIDTH % 8 == 0)
  #define DISPATCH_X0 BUFFER_WIDTH / THREAD_SIZE0
  #define WIDTH0_DISPATCH_DOESNT_OVERFLOW
#else
  #define DISPATCH_X0 BUFFER_WIDTH / THREAD_SIZE0 + 1
#endif

//#if (BUFFER_HEIGHT % THREAD_SIZE0 == 0)
#if (BUFFER_HEIGHT % 8 == 0)
  #define DISPATCH_Y0 BUFFER_HEIGHT / THREAD_SIZE0
  #define HEIGHT0_DISPATCH_DOESNT_OVERFLOW
#else
  #define DISPATCH_Y0 BUFFER_HEIGHT / THREAD_SIZE0 + 1
#endif

//#if (BUFFER_WIDTH % THREAD_SIZE1 == 0)
#if (BUFFER_WIDTH % 8 == 0)
  #define DISPATCH_X1 BUFFER_WIDTH / THREAD_SIZE1
  #define WIDTH1_DISPATCH_DOESNT_OVERFLOW
#else
  #define DISPATCH_X1 BUFFER_WIDTH / THREAD_SIZE1 + 1
#endif

//#if (BUFFER_HEIGHT % THREAD_SIZE1 == 0)
#if (BUFFER_HEIGHT % 8 == 0)
  #define DISPATCH_Y1 BUFFER_HEIGHT / THREAD_SIZE1
  #define HEIGHT1_DISPATCH_DOESNT_OVERFLOW
#else
  #define DISPATCH_Y1 BUFFER_HEIGHT / THREAD_SIZE1 + 1
#endif

static const uint WIDTH0 = BUFFER_WIDTH / 2;
static const uint WIDTH1 = BUFFER_WIDTH - WIDTH0;

static const uint HEIGHT0 = BUFFER_HEIGHT / 2;
static const uint HEIGHT1 = BUFFER_HEIGHT - HEIGHT0;


#if defined(ANALYSIS_ENABLE)


#include "draw_font.fxh"

// 0.0000000894069671630859375 = ((ieee754_half_decode(0x0002)
//                               - ieee754_half_decode(0x0001))
//                              / 2)
//                             + ieee754_half_decode(0x0001)
#define SMALLEST_FP16   asfloat(0x33C00000)
// 0.0014662756584584712982177734375 = 1.5 / 1023
#define SMALLEST_UINT10 asfloat(0x3AC0300C)


//#ifndef IGNORE_NEAR_BLACK_VALUES_FOR_CSP_DETECTION
  #define IGNORE_NEAR_BLACK_VALUES_FOR_CSP_DETECTION NO
//#endif


precise static const float PIXELS = uint(BUFFER_WIDTH) * uint(BUFFER_HEIGHT);


uniform float FRAMETIME
<
  source = "frametime";
>;


#define TEXTURE_OVERLAY_WIDTH  FONT_SIZE_56_CHAR_DIM.x * 26
#define TEXTURE_OVERLAY_HEIGHT FONT_SIZE_56_CHAR_DIM.y * (1                                \
                                                        + SHOW_NITS_VALUES_LINE_COUNT      \
                                                        + SHOW_NITS_FROM_CURSOR_LINE_COUNT \
                                                        + SHOW_CSPS_LINE_COUNT             \
                                                        + SHOW_CSP_FROM_CURSOR_LINE_COUNT  \
                                                        + 3)

texture2D TextureTextOverlay
<
  pooled = true;
>
{
  Width  = TEXTURE_OVERLAY_WIDTH;
  Height = TEXTURE_OVERLAY_HEIGHT;
  Format = RGBA8;
};

sampler2D<float4> SamplerTextOverlay
{
  Texture = TextureTextOverlay;
};

storage2D<float4> StorageTextOverlay
{
  Texture = TextureTextOverlay;
};

#endif //ANALYSIS_ENABLE

texture2D TextureNitsValues
<
  pooled = true;
>
{
  Width  = BUFFER_WIDTH;
  Height = BUFFER_HEIGHT;

  Format = R32F;
};

sampler2D<float> SamplerNitsValues
{
  Texture = TextureNitsValues;
};

storage2D<float> StorageNitsValues
{
  Texture = TextureNitsValues;
};

#if defined(ANALYSIS_ENABLE)

#if 0
static const uint _0_Dot_01_Percent_Pixels = BUFFER_WIDTH * BUFFER_HEIGHT * 0.01f;
static const uint _0_Dot_01_Percent_Texture_Width = _0_Dot_01_Percent_Pixels / 16;

texture2D TextureMaxNits0Dot01Percent
<
  pooled = true;
>
{
  Width  = _0_Dot_01_Percent_Texture_Width;
  Height = 16;

  Format = R32F;
};

sampler2D<float> SamplerMaxNits0Dot01Percent
{
  Texture = TextureMaxNits0Dot01Percent;
};

storage2D<float> StorageMaxNits0Dot01Percent
{
  Texture = TextureMaxNits0Dot01Percent;
};
#endif


#define CIE_TEXTURE_ENTRY_DIAGRAM_COLOUR   0
#define CIE_TEXTURE_ENTRY_DIAGRAM_BLACK_BG 1
#define CIE_TEXTURE_ENTRY_BT709_OUTLINE    2
#define CIE_TEXTURE_ENTRY_DCI_P3_OUTLINE   3
#define CIE_TEXTURE_ENTRY_BT2020_OUTLINE   4
#define CIE_TEXTURE_ENTRY_AP0_OUTLINE      5

//width and height description are in lilium__hdr_analysis.fx

texture2D TextureCieConsolidated
<
  source = CIE_TEXTURE_FILE_NAME;
  pooled = true;
>
{
  Width  = CIE_TEXTURE_WIDTH;
  Height = CIE_TEXTURE_HEIGHT;
  Format = RGBA8;
};

sampler2D<float4> SamplerCieConsolidated
{
  Texture = TextureCieConsolidated;
};

storage2D<float4> StorageCieConsolidated
{
  Texture = TextureCieConsolidated;
};

texture2D TextureCieCurrent
<
  pooled = true;
>
{
  Width  = CIE_1931_BG_WIDTH;
  Height = CIE_1931_BG_HEIGHT;
  Format = RGBA8;
};

sampler2D<float4> SamplerCieCurrent
{
  Texture = TextureCieCurrent;
};

storage2D<float4> StorageCieCurrent
{
  Texture = TextureCieCurrent;
};


#ifdef IS_HDR_CSP
texture2D TextureCsps
<
  pooled = true;
>
{
  Width  = BUFFER_WIDTH;
  Height = BUFFER_HEIGHT;

  Format = R8;
};

sampler2D<float> SamplerCsps
{
  Texture = TextureCsps;
};
#endif


static const float TEXTURE_LUMINANCE_WAVEFORM_BUFFER_WIDTH_FACTOR  = float(BUFFER_WIDTH)
                                                                   / float(TEXTURE_LUMINANCE_WAVEFORM_WIDTH);

static const float TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR = (float(BUFFER_WIDTH)  / 3840.f
                                                             + float(BUFFER_HEIGHT) / 2160.f)
                                                            / 2.f;

static const uint TEXTURE_LUMINANCE_WAVEFORM_SCALE_BORDER = TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR * 35.f + 0.5f;
static const uint TEXTURE_LUMINANCE_WAVEFORM_SCALE_FRAME  = TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR *  7.f + 0.5f;

//static const uint TEXTURE_LUMINANCE_WAVEFORM_FONT_SIZE =
//  clamp(uint(round(TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR * 27.f + 5.f)), 14, 32);

static const uint TEXTURE_LUMINANCE_WAVEFORM_SCALE_WIDTH  = TEXTURE_LUMINANCE_WAVEFORM_WIDTH
                                                          + (WAVE_FONT_SIZE_32_CHAR_DIM.x * 8) //8 chars for 10000.00
                                                          + uint(WAVE_FONT_SIZE_32_CHAR_DIM.x / 2.f + 0.5f)
                                                          + (TEXTURE_LUMINANCE_WAVEFORM_SCALE_BORDER * 2)
                                                          + (TEXTURE_LUMINANCE_WAVEFORM_SCALE_FRAME  * 3);

static const uint TEXTURE_LUMINANCE_WAVEFORM_SCALE_HEIGHT = TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT * 2
                                                          + uint(WAVE_FONT_SIZE_32_CHAR_DIM.y / 2.f - TEXTURE_LUMINANCE_WAVEFORM_SCALE_FRAME + 0.5f)
                                                          + (TEXTURE_LUMINANCE_WAVEFORM_SCALE_BORDER * 2)
                                                          + (TEXTURE_LUMINANCE_WAVEFORM_SCALE_FRAME  * 2);

static const float TEXTURE_LUMINANCE_WAVEFORM_SCALE_FACTOR_X = (TEXTURE_LUMINANCE_WAVEFORM_SCALE_WIDTH - 1.f)
                                                             / float(TEXTURE_LUMINANCE_WAVEFORM_WIDTH  - 1);

static const float TEXTURE_LUMINANCE_WAVEFORM_SCALE_FACTOR_Y = (TEXTURE_LUMINANCE_WAVEFORM_SCALE_HEIGHT     - 1.f)
                                                             / float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT - 1);

texture2D TextureLuminanceWaveform
<
  pooled = true;
>
{
  Width  = TEXTURE_LUMINANCE_WAVEFORM_WIDTH;
  Height = TEXTURE_LUMINANCE_WAVEFORM_HEIGHT;
  Format = RGBA8;
};

sampler2D<float4> SamplerLuminanceWaveform
{
  Texture = TextureLuminanceWaveform;
  MagFilter = POINT;
};

storage2D<float4> StorageLuminanceWaveform
{
  Texture = TextureLuminanceWaveform;
};

texture2D TextureLuminanceWaveformScale
<
  pooled = true;
>
{
  Width  = TEXTURE_LUMINANCE_WAVEFORM_SCALE_WIDTH;
  Height = TEXTURE_LUMINANCE_WAVEFORM_SCALE_HEIGHT;
  Format = RGBA8;
};

sampler2D<float4> SamplerLuminanceWaveformScale
{
  Texture = TextureLuminanceWaveformScale;
};

storage2D<float4> StorageLuminanceWaveformScale
{
  Texture = TextureLuminanceWaveformScale;
};

texture2D TextureLuminanceWaveformFinal
<
  pooled = true;
>
{
  Width  = TEXTURE_LUMINANCE_WAVEFORM_SCALE_WIDTH;
  Height = TEXTURE_LUMINANCE_WAVEFORM_SCALE_HEIGHT;
  Format = RGBA8;
};

sampler2D<float4> SamplerLuminanceWaveformFinal
{
  Texture   = TextureLuminanceWaveformFinal;
  MagFilter = POINT;
};

#endif //ANALYSIS_ENABLE

// consolidated texture start

#define INTERMEDIATE_NITS_VALUES_X_OFFSET 0
#define INTERMEDIATE_NITS_VALUES_Y_OFFSET 0


#define CSP_COUNTER_X_OFFSET 0
#define CSP_COUNTER_Y_OFFSET 6


// (12) 4x max, avg and min Nits
#define FINAL_4_NITS_VALUES_X_OFFSET 0
#define FINAL_4_NITS_VALUES_Y_OFFSET 12
static const int2 COORDS_FINAL_4_MAX_NITS_VALUE0 = int2(     FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_AVG_NITS_VALUE0 = int2( 1 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_MIN_NITS_VALUE0 = int2( 2 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_MAX_NITS_VALUE1 = int2( 3 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_AVG_NITS_VALUE1 = int2( 4 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_MIN_NITS_VALUE1 = int2( 5 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_MAX_NITS_VALUE2 = int2( 6 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_AVG_NITS_VALUE2 = int2( 7 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_MIN_NITS_VALUE2 = int2( 8 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_MAX_NITS_VALUE3 = int2( 9 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_AVG_NITS_VALUE3 = int2(10 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_FINAL_4_MIN_NITS_VALUE3 = int2(11 + FINAL_4_NITS_VALUES_X_OFFSET, FINAL_4_NITS_VALUES_Y_OFFSET);


// (4) max, max 99.99%, avg and min Nits
#define MAX_AVG_MIN_NITS_VALUES_X_OFFSET 12 + FINAL_4_NITS_VALUES_X_OFFSET
#define MAX_AVG_MIN_NITS_VALUES_Y_OFFSET 12
static const int2 COORDS_MAX_NITS_VALUE   = int2(    MAX_AVG_MIN_NITS_VALUES_X_OFFSET, MAX_AVG_MIN_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_MAX_NITS99_VALUE = int2(1 + MAX_AVG_MIN_NITS_VALUES_X_OFFSET, MAX_AVG_MIN_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_AVG_NITS_VALUE   = int2(2 + MAX_AVG_MIN_NITS_VALUES_X_OFFSET, MAX_AVG_MIN_NITS_VALUES_Y_OFFSET);
static const int2 COORDS_MIN_NITS_VALUE   = int2(3 + MAX_AVG_MIN_NITS_VALUES_X_OFFSET, MAX_AVG_MIN_NITS_VALUES_Y_OFFSET);


// (5) CSP counter for BT.709, DCI-P3, BT.2020, AP0 and invalid
#define CSP_COUNTER_FINAL_X_OFFSET  4 + MAX_AVG_MIN_NITS_VALUES_X_OFFSET
#define CSP_COUNTER_FINAL_Y_OFFSET 12
static const int2 COORDS_CSP_PERCENTAGE_BT709   = int2(    CSP_COUNTER_FINAL_X_OFFSET, CSP_COUNTER_FINAL_Y_OFFSET);
static const int2 COORDS_CSP_PERCENTAGE_DCI_P3  = int2(1 + CSP_COUNTER_FINAL_X_OFFSET, CSP_COUNTER_FINAL_Y_OFFSET);
static const int2 COORDS_CSP_PERCENTAGE_BT2020  = int2(2 + CSP_COUNTER_FINAL_X_OFFSET, CSP_COUNTER_FINAL_Y_OFFSET);
static const int2 COORDS_CSP_PERCENTAGE_AP0     = int2(3 + CSP_COUNTER_FINAL_X_OFFSET, CSP_COUNTER_FINAL_Y_OFFSET);
static const int2 COORDS_CSP_PERCENTAGE_INVALID = int2(4 + CSP_COUNTER_FINAL_X_OFFSET, CSP_COUNTER_FINAL_Y_OFFSET);


// (8) show values for max, avg and min Nits plus CSP % for BT.709, DCI-P3, BT.2020, AP0 and invalid
#define SHOW_VALUES_X_OFFSET  5 + CSP_COUNTER_FINAL_X_OFFSET
#define SHOW_VALUES_Y_OFFSET 12
static const int2 COORDS_SHOW_MAX_NITS           = int2(    SHOW_VALUES_X_OFFSET, SHOW_VALUES_Y_OFFSET);
static const int2 COORDS_SHOW_AVG_NITS           = int2(1 + SHOW_VALUES_X_OFFSET, SHOW_VALUES_Y_OFFSET);
static const int2 COORDS_SHOW_MIN_NITS           = int2(2 + SHOW_VALUES_X_OFFSET, SHOW_VALUES_Y_OFFSET);
static const int2 COORDS_SHOW_PERCENTAGE_BT709   = int2(3 + SHOW_VALUES_X_OFFSET, SHOW_VALUES_Y_OFFSET);
static const int2 COORDS_SHOW_PERCENTAGE_DCI_P3  = int2(4 + SHOW_VALUES_X_OFFSET, SHOW_VALUES_Y_OFFSET);
static const int2 COORDS_SHOW_PERCENTAGE_BT2020  = int2(5 + SHOW_VALUES_X_OFFSET, SHOW_VALUES_Y_OFFSET);
static const int2 COORDS_SHOW_PERCENTAGE_AP0     = int2(6 + SHOW_VALUES_X_OFFSET, SHOW_VALUES_Y_OFFSET);
static const int2 COORDS_SHOW_PERCENTAGE_INVALID = int2(7 + SHOW_VALUES_X_OFFSET, SHOW_VALUES_Y_OFFSET);


// (1) adaptive Nits for tone mapping
#define ADAPTIVE_NITS_X_OFFSET  8 + SHOW_VALUES_X_OFFSET
#define ADAPTIVE_NITS_Y_OFFSET 12
static const int2 COORDS_ADAPTIVE_NITS = int2(ADAPTIVE_NITS_X_OFFSET, ADAPTIVE_NITS_Y_OFFSET);


// (12) averaged Nits over the last 10 frames for adaptive Nits
#define AVERAGE_MAX_NITS_X_OFFSET  1 + ADAPTIVE_NITS_X_OFFSET
#define AVERAGE_MAX_NITS_Y_OFFSET 12
static const int2 COORDS_AVERAGE_MAX_NITS_CUR = int2(     AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_0   = int2( 1 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_1   = int2( 2 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_2   = int2( 3 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_3   = int2( 4 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_4   = int2( 5 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_5   = int2( 6 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_6   = int2( 7 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_7   = int2( 8 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_8   = int2( 9 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGE_MAX_NITS_9   = int2(10 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);
static const int2 COORDS_AVERAGED_MAX_NITS    = int2(11 + AVERAGE_MAX_NITS_X_OFFSET, AVERAGE_MAX_NITS_Y_OFFSET);


// (5) check if redraw of text is needed for overlay
#define CHECK_OVERLAY_REDRAW_X_OFFSET 12 + AVERAGE_MAX_NITS_X_OFFSET
#define CHECK_OVERLAY_REDRAW_Y_OFFSET 12
static const int2 COORDS_CHECK_OVERLAY_REDRAW0 = int2(    CHECK_OVERLAY_REDRAW_X_OFFSET, CHECK_OVERLAY_REDRAW_Y_OFFSET);
static const int2 COORDS_CHECK_OVERLAY_REDRAW1 = int2(1 + CHECK_OVERLAY_REDRAW_X_OFFSET, CHECK_OVERLAY_REDRAW_Y_OFFSET);
static const int2 COORDS_CHECK_OVERLAY_REDRAW2 = int2(2 + CHECK_OVERLAY_REDRAW_X_OFFSET, CHECK_OVERLAY_REDRAW_Y_OFFSET);
static const int2 COORDS_CHECK_OVERLAY_REDRAW3 = int2(3 + CHECK_OVERLAY_REDRAW_X_OFFSET, CHECK_OVERLAY_REDRAW_Y_OFFSET);
static const int2 COORDS_CHECK_OVERLAY_REDRAW4 = int2(4 + CHECK_OVERLAY_REDRAW_X_OFFSET, CHECK_OVERLAY_REDRAW_Y_OFFSET);


// (3) offsets for overlay text blocks
#define OVERLAY_TEXT_Y_OFFSETS_X_OFFSET  5 + CHECK_OVERLAY_REDRAW_X_OFFSET
#define OVERLAY_TEXT_Y_OFFSETS_Y_OFFSET 12
static const int2 COORDS_OVERLAY_TEXT_Y_OFFSET_CURSOR_NITS = int2(    OVERLAY_TEXT_Y_OFFSETS_X_OFFSET, OVERLAY_TEXT_Y_OFFSETS_Y_OFFSET);
static const int2 COORDS_OVERLAY_TEXT_Y_OFFSET_CSPS        = int2(1 + OVERLAY_TEXT_Y_OFFSETS_X_OFFSET, OVERLAY_TEXT_Y_OFFSETS_Y_OFFSET);
static const int2 COORDS_OVERLAY_TEXT_Y_OFFSET_CURSOR_CSP  = int2(2 + OVERLAY_TEXT_Y_OFFSETS_X_OFFSET, OVERLAY_TEXT_Y_OFFSETS_Y_OFFSET);


// (1) update Nits values and CSP percentages for the overlay
#define UPDATE_OVERLAY_PERCENTAGES_X_OFFSET  3 + OVERLAY_TEXT_Y_OFFSETS_X_OFFSET
#define UPDATE_OVERLAY_PERCENTAGES_Y_OFFSET 12
static const int2 COORDS_UPDATE_OVERLAY_PERCENTAGES = int2(UPDATE_OVERLAY_PERCENTAGES_X_OFFSET, UPDATE_OVERLAY_PERCENTAGES_Y_OFFSET);


// (3) luminance waveform variables
#define LUMINANCE_WAVEFORM_VARIABLES_X_OFFSET  1 + UPDATE_OVERLAY_PERCENTAGES_X_OFFSET
#define LUMINANCE_WAVEFORM_VARIABLES_Y_OFFSET 12
static const int2 COORDS_LUMINANCE_WAVEFORM_LAST_SIZE_X       = int2(    LUMINANCE_WAVEFORM_VARIABLES_X_OFFSET, LUMINANCE_WAVEFORM_VARIABLES_Y_OFFSET);
static const int2 COORDS_LUMINANCE_WAVEFORM_LAST_SIZE_Y       = int2(1 + LUMINANCE_WAVEFORM_VARIABLES_X_OFFSET, LUMINANCE_WAVEFORM_VARIABLES_Y_OFFSET);
static const int2 COORDS_LUMINANCE_WAVEFORM_LAST_CUTOFF_POINT = int2(2 + LUMINANCE_WAVEFORM_VARIABLES_X_OFFSET, LUMINANCE_WAVEFORM_VARIABLES_Y_OFFSET);


#define CONSOLIDATED_TEXTURE_SIZE_WIDTH  BUFFER_WIDTH
#define CONSOLIDATED_TEXTURE_SIZE_HEIGHT 13


texture2D TextureConsolidated
<
  pooled = true;
>
{
  Width  = CONSOLIDATED_TEXTURE_SIZE_WIDTH;
  Height = CONSOLIDATED_TEXTURE_SIZE_HEIGHT;
  Format = R32F;
};

sampler2D<float> SamplerConsolidated
{
  Texture = TextureConsolidated;
};

storage2D<float> StorageConsolidated
{
  Texture = TextureConsolidated;
};

// consolidated texture end

#if defined(ANALYSIS_ENABLE)

float3 MapBt709IntoCurrentCsp(
  float3 Colour,
  float  Brightness)
{
#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB)

  return Csp::Map::Bt709Into::Scrgb(Colour, Brightness);

#elif (ACTUAL_COLOUR_SPACE == CSP_HDR10)

  return Csp::Map::Bt709Into::Hdr10(Colour, Brightness);

#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)

  return Csp::Map::Bt709Into::Hlg(Colour, Brightness);

#elif (ACTUAL_COLOUR_SPACE == CSP_PS5)

  return Csp::Map::Bt709Into::Ps5(Colour, Brightness);

#elif (ACTUAL_COLOUR_SPACE == CSP_SRGB)

  return ENCODE_SDR(Colour * (Brightness / 100.f));

#else

  return 0.f;

#endif
}


static const float4x3 HeatmapSteps0 = float4x3(
  100.f, 203.f, 400.f,
  100.f, 203.f, 400.f,
  100.f, 203.f, 400.f,
  100.f, 203.f, 400.f);

static const float4x3 HeatmapSteps1 = float4x3(
  1000.f, 4000.f, 10000.f,
  1000.f, 2000.f,  4000.f,
  1000.f, 1500.f,  2000.f,
   600.f,  800.f,  1000.f);

float HeatmapFadeIn(float Y, float CurrentStep, float NormaliseTo)
{
  return (Y - CurrentStep)
       / (NormaliseTo - CurrentStep);
}

float HeatmapFadeOut(float Y, float CurrentStep, float NormaliseTo)
{
  return 1.f - HeatmapFadeIn(Y, CurrentStep, NormaliseTo);
}

#define HEATMAP_MODE_10000 0
#define HEATMAP_MODE_4000  1
#define HEATMAP_MODE_2000  2
#define HEATMAP_MODE_1000  3

float3 HeatmapRgbValues(
  float Y,
#ifdef IS_HDR_CSP
  uint  Mode,
#endif
  bool  WaveformOutput)
{
  float3 output;


#ifdef IS_HDR_CSP
  #define HEATMAP_STEP_0 HeatmapSteps0[Mode][0]
  #define HEATMAP_STEP_1 HeatmapSteps0[Mode][1]
  #define HEATMAP_STEP_2 HeatmapSteps0[Mode][2]
  #define HEATMAP_STEP_3 HeatmapSteps1[Mode][0]
  #define HEATMAP_STEP_4 HeatmapSteps1[Mode][1]
  #define HEATMAP_STEP_5 HeatmapSteps1[Mode][2]
#else
  #define HEATMAP_STEP_0   1.f
  #define HEATMAP_STEP_1  18.f
  #define HEATMAP_STEP_2  50.f
  #define HEATMAP_STEP_3  75.f
  #define HEATMAP_STEP_4  87.5f
  #define HEATMAP_STEP_5 100.f
#endif


  if (IsNAN(Y))
  {
    output.r = 0.f;
    output.g = 0.f;
    output.b = 0.f;
  }
  else if (Y < 0.f)
  {
    output.r = 0.f;
    output.g = 0.f;
    output.b = 6.25f;
  }
  else if (Y <= HEATMAP_STEP_0) // <= 100nits
  {
    //shades of grey
    float clamped = !WaveformOutput ? Y / HEATMAP_STEP_0 * 0.25f
                                    : 0.666f;
    output.rgb = clamped;
  }
  else if (Y <= HEATMAP_STEP_1) // <= 203nits
  {
    //(blue+green) to green
    output.r = 0.f;
    output.g = 1.f;
    output.b = HeatmapFadeOut(Y, HEATMAP_STEP_0, HEATMAP_STEP_1);
  }
  else if (Y <= HEATMAP_STEP_2) // <= 400nits
  {
    //green to yellow
    output.r = HeatmapFadeIn(Y, HEATMAP_STEP_1, HEATMAP_STEP_2);
    output.g = 1.f;
    output.b = 0.f;
  }
  else if (Y <= HEATMAP_STEP_3) // <= 1000nits
  {
    //yellow to red
    output.r = 1.f;
    output.g = HeatmapFadeOut(Y, HEATMAP_STEP_2, HEATMAP_STEP_3);
    output.b = 0.f;
  }
  else if (Y <= HEATMAP_STEP_4) // <= 4000nits
  {
    //red to pink
    output.r = 1.f;
    output.g = 0.f;
    output.b = HeatmapFadeIn(Y, HEATMAP_STEP_3, HEATMAP_STEP_4);
  }
  else if(Y <= HEATMAP_STEP_5) // <= 10000nits
  {
    //pink to blue
    output.r = HeatmapFadeOut(Y, HEATMAP_STEP_4, HEATMAP_STEP_5);
    output.g = 0.f;
    output.b = 1.f;
  }
  else // > 10000nits
  {
    output.r = 6.25f;
    output.g = 0.f;
    output.b = 0.f;
  }

  return output;
}


// calls HeatmapRgbValues with predefined parameters
float3 WaveformRgbValues(
  const float Y)
{
#ifdef IS_HDR_CSP
  // LUMINANCE_WAVEFORM_CUTOFF_POINT values match heatmap modes 1:1
  return HeatmapRgbValues(Y, LUMINANCE_WAVEFORM_CUTOFF_POINT, true);
#else
  return HeatmapRgbValues(Y, true);
#endif
}

namespace Waveform
{

  struct SWaveformData
  {
    int   borderSize;
    int   frameSize;
    int2  charDimensions;
#ifndef IS_HDR_CSP
    int   charDimensionXForPercent;
#endif
    int2  atlasOffset;
    int2  waveformArea;
#ifdef IS_HDR_CSP
    int   cutoffOffset;
    #define WAVEDAT_CUTOFFSET waveDat.cutoffOffset
    int   tickPoints[16];
#else
    #define WAVEDAT_CUTOFFSET 0
    int   tickPoints[14];
#endif
    int   fontSpacer;
    int2  offsetToFrame;
    int2  textOffset;
    int   tickXOffset;
    int   lowerFrameStart;
    int2  endXY;
    int   endYminus1;
  };

  SWaveformData GetData()
  {
    SWaveformData waveDat;

    const float2 waveformScaleFactorXY = clamp(_LUMINANCE_WAVEFORM_SIZE / 100.f, 0.5f, float2(1.f, 2.f));

    const float waveformScaleFactor =
#ifdef IS_HDR_CSP
      (waveformScaleFactorXY.x + waveformScaleFactorXY.y) / 2.f;
#else
      waveformScaleFactorXY.y / (LUMINANCE_WAVEFORM_DEFAULT_HEIGHT / 100.f);
#endif

    const float borderAndFrameSizeFactor = max(waveformScaleFactor, 0.75f);
#ifdef IS_HDR_CSP
    const float fontSizeFactor = max(waveformScaleFactor, 0.85f);
#else
    #define fontSizeFactor waveformScaleFactor
#endif

    static const int maxBorderSize = int(TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR * 35.f + 0.5f);
    static const int maxFrameSize  = int(TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR *  7.f + 0.5f);

    waveDat.borderSize = clamp(int(TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR * 35.f * borderAndFrameSizeFactor + 0.5f), 10, maxBorderSize);
    waveDat.frameSize  = clamp(int(TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR *  7.f * borderAndFrameSizeFactor + 0.5f),  4, maxFrameSize);

    static const uint maxFontSize =
      clamp(uint(((TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR *
#ifdef IS_HDR_CSP
                                                              27.f + 5.f
#else
                                                              28.f + 3.f
#endif
                                                                        ) / 2.f + 0.5f)) * 2, 12, 32);

    const uint fontSize =
      clamp(uint(((TEXTURE_LUMINANCE_WAVEFORM_BUFFER_FACTOR *
#ifdef IS_HDR_CSP
                                                              27.f + 5.f
#else
                                                              28.f + 3.f
#endif
                                                                        ) / 2.f * fontSizeFactor + 0.5f)) * 2, 12, maxFontSize);

    const uint charArrayEntry = 32 - fontSize;

    const uint atlasEntry = charArrayEntry / 2;

#ifndef IS_HDR_CSP
    waveDat.charDimensionXForPercent = WaveCharSize[charArrayEntry];

    waveDat.charDimensions = int2(waveDat.charDimensionXForPercent - 2, WaveCharSize[charArrayEntry + 1]);
#else
    waveDat.charDimensions = int2(WaveCharSize[charArrayEntry] - 2, WaveCharSize[charArrayEntry + 1]);
#endif

    waveDat.atlasOffset = int2(WaveAtlasXOffset[atlasEntry], WAVE_TEXTURE_OFFSET.y);

#ifdef IS_HDR_CSP
    const int maxChars = LUMINANCE_WAVEFORM_CUTOFF_POINT == 0 ? 8
                                                              : 7;
#else
    const int maxChars = 7;
#endif

    const int textWidth  = waveDat.charDimensions.x * maxChars;
    const int tickSpacer = int(float(waveDat.charDimensions.x) / 2.f + 0.5f);

    waveDat.fontSpacer = int(float(waveDat.charDimensions.y) / 2.f - float(waveDat.frameSize) + 0.5f);

    waveDat.offsetToFrame = int2(waveDat.borderSize + textWidth + tickSpacer + waveDat.frameSize,
                                 waveDat.borderSize + waveDat.fontSpacer);

#ifdef IS_HDR_CSP
    static const int cutoffPoints[16] = {
      int(0),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(4000.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(2000.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(1000.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq( 400.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq( 203.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq( 100.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(  50.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(  25.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(  10.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(   5.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(   2.5f ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(   1.f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(   0.25f) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (Csp::Trc::NitsTo::Pq(   0.05f) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int(                                                                                   float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT)   * waveformScaleFactorXY.y + 0.5f) };
#else
    waveDat.tickPoints = {
      int(0),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.875f ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.75f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.6f   ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.5f   ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.35f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.25f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.18f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.1f   ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.05f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.025f ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.01f  ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
#if (OVERWRITE_SDR_GAMMA == GAMMA_UNSET \
  || OVERWRITE_SDR_GAMMA == GAMMA_22    \
  || OVERWRITE_SDR_GAMMA == GAMMA_24)
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.0025f) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
#else
      int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT) - (ENCODE_SDR(0.004f ) * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) * waveformScaleFactorXY.y + 0.5f),
#endif
      int(                                                                        float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT)   * waveformScaleFactorXY.y + 0.5f) };
#endif

    waveDat.waveformArea =
      int2(TEXTURE_LUMINANCE_WAVEFORM_WIDTH * waveformScaleFactorXY.x,
#ifdef IS_HDR_CSP
           cutoffPoints[15] - cutoffPoints[LUMINANCE_WAVEFORM_CUTOFF_POINT]
#else
           waveDat.tickPoints[13]
#endif
           );

#ifdef IS_HDR_CSP
    if (LUMINANCE_WAVEFORM_CUTOFF_POINT == 0)
    {
      waveDat.cutoffOffset = 0;

      waveDat.tickPoints = {
        int(0),
        int(cutoffPoints[ 1]),
        int(cutoffPoints[ 2]),
        int(cutoffPoints[ 3]),
        int(cutoffPoints[ 4]),
        int(cutoffPoints[ 5]),
        int(cutoffPoints[ 6]),
        int(cutoffPoints[ 7]),
        int(cutoffPoints[ 8]),
        int(cutoffPoints[ 9]),
        int(cutoffPoints[10]),
        int(cutoffPoints[11]),
        int(cutoffPoints[12]),
        int(cutoffPoints[13]),
        int(cutoffPoints[14]),
        int(cutoffPoints[15]) };
    }
    else if (LUMINANCE_WAVEFORM_CUTOFF_POINT == 1)
    {
      waveDat.cutoffOffset = cutoffPoints[1];

      waveDat.tickPoints = {
        int(-100),
        int(0),
        int(cutoffPoints[ 2] - waveDat.cutoffOffset),
        int(cutoffPoints[ 3] - waveDat.cutoffOffset),
        int(cutoffPoints[ 4] - waveDat.cutoffOffset),
        int(cutoffPoints[ 5] - waveDat.cutoffOffset),
        int(cutoffPoints[ 6] - waveDat.cutoffOffset),
        int(cutoffPoints[ 7] - waveDat.cutoffOffset),
        int(cutoffPoints[ 8] - waveDat.cutoffOffset),
        int(cutoffPoints[ 9] - waveDat.cutoffOffset),
        int(cutoffPoints[10] - waveDat.cutoffOffset),
        int(cutoffPoints[11] - waveDat.cutoffOffset),
        int(cutoffPoints[12] - waveDat.cutoffOffset),
        int(cutoffPoints[13] - waveDat.cutoffOffset),
        int(cutoffPoints[14] - waveDat.cutoffOffset),
        int(cutoffPoints[15] - waveDat.cutoffOffset) };
    }
    else if (LUMINANCE_WAVEFORM_CUTOFF_POINT == 2)
    {
      waveDat.cutoffOffset = cutoffPoints[2];

      waveDat.tickPoints = {
        int(-100),
        int(-100),
        int(0),
        int(cutoffPoints[ 3] - waveDat.cutoffOffset),
        int(cutoffPoints[ 4] - waveDat.cutoffOffset),
        int(cutoffPoints[ 5] - waveDat.cutoffOffset),
        int(cutoffPoints[ 6] - waveDat.cutoffOffset),
        int(cutoffPoints[ 7] - waveDat.cutoffOffset),
        int(cutoffPoints[ 8] - waveDat.cutoffOffset),
        int(cutoffPoints[ 9] - waveDat.cutoffOffset),
        int(cutoffPoints[10] - waveDat.cutoffOffset),
        int(cutoffPoints[11] - waveDat.cutoffOffset),
        int(cutoffPoints[12] - waveDat.cutoffOffset),
        int(cutoffPoints[13] - waveDat.cutoffOffset),
        int(cutoffPoints[14] - waveDat.cutoffOffset),
        int(cutoffPoints[15] - waveDat.cutoffOffset) };
    }
    else //if (LUMINANCE_WAVEFORM_CUTOFF_POINT == 3)
    {
      waveDat.cutoffOffset = cutoffPoints[3];

      waveDat.tickPoints = {
        int(-100),
        int(-100),
        int(-100),
        int(0),
        int(cutoffPoints[ 4] - waveDat.cutoffOffset),
        int(cutoffPoints[ 5] - waveDat.cutoffOffset),
        int(cutoffPoints[ 6] - waveDat.cutoffOffset),
        int(cutoffPoints[ 7] - waveDat.cutoffOffset),
        int(cutoffPoints[ 8] - waveDat.cutoffOffset),
        int(cutoffPoints[ 9] - waveDat.cutoffOffset),
        int(cutoffPoints[10] - waveDat.cutoffOffset),
        int(cutoffPoints[11] - waveDat.cutoffOffset),
        int(cutoffPoints[12] - waveDat.cutoffOffset),
        int(cutoffPoints[13] - waveDat.cutoffOffset),
        int(cutoffPoints[14] - waveDat.cutoffOffset),
        int(cutoffPoints[15] - waveDat.cutoffOffset) };
    }
#endif

    waveDat.textOffset = int2(0, int(float(waveDat.charDimensions.y) / 2.f + 0.5f));

    waveDat.tickXOffset = waveDat.borderSize
                        + textWidth
                        + tickSpacer;

    waveDat.lowerFrameStart = waveDat.frameSize
                            + waveDat.waveformArea.y;

    waveDat.endXY = waveDat.frameSize * 2
                  + waveDat.waveformArea;

    waveDat.endYminus1 = waveDat.endXY.y - 1;

    return waveDat;
  }

  int2 GetActiveArea()
  {
    SWaveformData waveDat = GetData();

    return waveDat.offsetToFrame
         + waveDat.frameSize
         + waveDat.waveformArea
         + waveDat.frameSize
         + int2(0, waveDat.fontSpacer)
         + waveDat.borderSize;
  }

  int2 GetNitsOffset(
    const int ActiveBorderSize,
    const int ActiveFrameSize,
    const int ActiveFontSpacer,
    const int YOffset)
  {
    return int2(ActiveBorderSize,
                ActiveBorderSize + ActiveFontSpacer + ActiveFrameSize + YOffset);
  } //GetNitsOffset

  void DrawCharToScale(
    const int  Char,
    const int2 CharDim,
    const int2 AtlasOffset,
    const int2 Pos,
    const int  CharCount)
  {
    const int2 charOffset = int2(AtlasOffset.x,
                                 AtlasOffset.y + (Char * CharDim.y));

    int charDimX = CharDim.x;

    if (Char == _percent_w)
    {
      charDimX -= 2;
    }

    const int2 currentPos = Pos + int2(CharCount * charDimX, 0);

    int startX = 1;
    int stopX  = CharDim.x + 1;

    if (Char == _percent_w)
    {
      startX = 0;
      stopX  = CharDim.x;
    }

    for (int x = startX; x < stopX; x++)
    {
      for (int y = 0; y < CharDim.y; y++)
      {
        int2 currentOffset = int2(x, y);
        int2 currentDrawOffset = currentPos + currentOffset;

        float4 currentPixel = tex2Dfetch(StorageFontAtlasConsolidated, charOffset + currentOffset);

        tex2Dstore(StorageLuminanceWaveformScale, currentDrawOffset, currentPixel);
      }
    }
    return;
  } //DrawCharToScale

}

void CS_RenderLuminanceWaveformScale()
{
  if (tex2Dfetch(StorageConsolidated, COORDS_LUMINANCE_WAVEFORM_LAST_SIZE_X).x       != _LUMINANCE_WAVEFORM_SIZE.x
   || tex2Dfetch(StorageConsolidated, COORDS_LUMINANCE_WAVEFORM_LAST_SIZE_Y).x       != _LUMINANCE_WAVEFORM_SIZE.y
#ifdef IS_HDR_CSP
   || tex2Dfetch(StorageConsolidated, COORDS_LUMINANCE_WAVEFORM_LAST_CUTOFF_POINT).x != LUMINANCE_WAVEFORM_CUTOFF_POINT
#endif
  )
  {
    //make background all black
    for (int x = 0; x < TEXTURE_LUMINANCE_WAVEFORM_SCALE_WIDTH; x++)
    {
      for (int y = 0; y < TEXTURE_LUMINANCE_WAVEFORM_SCALE_HEIGHT; y++)
      {
        tex2Dstore(StorageLuminanceWaveformScale, int2(x, y), float4(0.f, 0.f, 0.f, 0.f));
      }
    }

    Waveform::SWaveformData waveDat = Waveform::GetData();

#ifdef IS_HDR_CSP

    const int2 nits10000_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 0]);
    const int2 nits_4000_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 1]);
    const int2 nits_2000_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 2]);
    const int2 nits_1000_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 3]);
    const int2 nits__400_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 4]);
    const int2 nits__203_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 5]);
    const int2 nits__100_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 6]);
    const int2 nits___50_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 7]);
    const int2 nits___25_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 8]);
    const int2 nits___10_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 9]);
    const int2 nits____5_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[10]);
    const int2 nits____2_50Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[11]);
    const int2 nits____1_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[12]);
    const int2 nits____0_25Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[13]);
    const int2 nits____0_05Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[14]);
    const int2 nits____0_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[15]);


    const int2 text10000_00Offset = nits10000_00Offset - waveDat.textOffset;
    const int2 text_4000_00Offset = nits_4000_00Offset - waveDat.textOffset;
    const int2 text_2000_00Offset = nits_2000_00Offset - waveDat.textOffset;
    const int2 text_1000_00Offset = nits_1000_00Offset - waveDat.textOffset;
    const int2 text__400_00Offset = nits__400_00Offset - waveDat.textOffset;
    const int2 text__203_00Offset = nits__203_00Offset - waveDat.textOffset;
    const int2 text__100_00Offset = nits__100_00Offset - waveDat.textOffset;
    const int2 text___50_00Offset = nits___50_00Offset - waveDat.textOffset;
    const int2 text___25_00Offset = nits___25_00Offset - waveDat.textOffset;
    const int2 text___10_00Offset = nits___10_00Offset - waveDat.textOffset;
    const int2 text____5_00Offset = nits____5_00Offset - waveDat.textOffset;
    const int2 text____2_50Offset = nits____2_50Offset - waveDat.textOffset;
    const int2 text____1_00Offset = nits____1_00Offset - waveDat.textOffset;
    const int2 text____0_25Offset = nits____0_25Offset - waveDat.textOffset;
    const int2 text____0_05Offset = nits____0_05Offset - waveDat.textOffset;
    const int2 text____0_00Offset = nits____0_00Offset - waveDat.textOffset;

    int charOffsets[8];

    if (LUMINANCE_WAVEFORM_CUTOFF_POINT == 0)
    {
      charOffsets = {
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7 };
    }
    else //if (LUMINANCE_WAVEFORM_CUTOFF_POINT > 0)
    {
      charOffsets = {
        0,
        0,
        1,
        2,
        3,
        4,
        5,
        6 };
    }

    if (LUMINANCE_WAVEFORM_CUTOFF_POINT == 0)
    {
      Waveform::DrawCharToScale(  _1_w, waveDat.charDimensions, waveDat.atlasOffset, text10000_00Offset, charOffsets[0]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text10000_00Offset, charOffsets[1]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text10000_00Offset, charOffsets[2]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text10000_00Offset, charOffsets[3]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text10000_00Offset, charOffsets[4]);
      Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text10000_00Offset, charOffsets[5]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text10000_00Offset, charOffsets[6]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text10000_00Offset, charOffsets[7]);
    }

    if (LUMINANCE_WAVEFORM_CUTOFF_POINT <= 1)
    {
      Waveform::DrawCharToScale(  _4_w, waveDat.charDimensions, waveDat.atlasOffset, text_4000_00Offset, charOffsets[1]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_4000_00Offset, charOffsets[2]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_4000_00Offset, charOffsets[3]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_4000_00Offset, charOffsets[4]);
      Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text_4000_00Offset, charOffsets[5]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_4000_00Offset, charOffsets[6]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_4000_00Offset, charOffsets[7]);
    }

    if (LUMINANCE_WAVEFORM_CUTOFF_POINT <= 2)
    {
      Waveform::DrawCharToScale(  _2_w, waveDat.charDimensions, waveDat.atlasOffset, text_2000_00Offset, charOffsets[1]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_2000_00Offset, charOffsets[2]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_2000_00Offset, charOffsets[3]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_2000_00Offset, charOffsets[4]);
      Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text_2000_00Offset, charOffsets[5]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_2000_00Offset, charOffsets[6]);
      Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_2000_00Offset, charOffsets[7]);
    }

    Waveform::DrawCharToScale(  _1_w, waveDat.charDimensions, waveDat.atlasOffset, text_1000_00Offset, charOffsets[1]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_1000_00Offset, charOffsets[2]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_1000_00Offset, charOffsets[3]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_1000_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text_1000_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_1000_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text_1000_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _4_w, waveDat.charDimensions, waveDat.atlasOffset, text__400_00Offset, charOffsets[2]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__400_00Offset, charOffsets[3]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__400_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text__400_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__400_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__400_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _2_w, waveDat.charDimensions, waveDat.atlasOffset, text__203_00Offset, charOffsets[2]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__203_00Offset, charOffsets[3]);
    Waveform::DrawCharToScale(  _3_w, waveDat.charDimensions, waveDat.atlasOffset, text__203_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text__203_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__203_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__203_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _1_w, waveDat.charDimensions, waveDat.atlasOffset, text__100_00Offset, charOffsets[2]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__100_00Offset, charOffsets[3]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__100_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text__100_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__100_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text__100_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _5_w, waveDat.charDimensions, waveDat.atlasOffset, text___50_00Offset, charOffsets[3]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text___50_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text___50_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text___50_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text___50_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _2_w, waveDat.charDimensions, waveDat.atlasOffset, text___25_00Offset, charOffsets[3]);
    Waveform::DrawCharToScale(  _5_w, waveDat.charDimensions, waveDat.atlasOffset, text___25_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text___25_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text___25_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text___25_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _1_w, waveDat.charDimensions, waveDat.atlasOffset, text___10_00Offset, charOffsets[3]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text___10_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text___10_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text___10_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text___10_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _5_w, waveDat.charDimensions, waveDat.atlasOffset, text____5_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text____5_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____5_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____5_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _2_w, waveDat.charDimensions, waveDat.atlasOffset, text____2_50Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text____2_50Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _5_w, waveDat.charDimensions, waveDat.atlasOffset, text____2_50Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____2_50Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _1_w, waveDat.charDimensions, waveDat.atlasOffset, text____1_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text____1_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____1_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____1_00Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_25Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_25Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _2_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_25Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _5_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_25Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_05Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_05Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_05Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _5_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_05Offset, charOffsets[7]);

    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_00Offset, charOffsets[4]);
    Waveform::DrawCharToScale(_dot_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_00Offset, charOffsets[5]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_00Offset, charOffsets[6]);
    Waveform::DrawCharToScale(  _0_w, waveDat.charDimensions, waveDat.atlasOffset, text____0_00Offset, charOffsets[7]);

#else

    const int2 nits100_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 0]);
    const int2 nits_87_50Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 1]);
    const int2 nits_75_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 2]);
    const int2 nits_60_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 3]);
    const int2 nits_50_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 4]);
    const int2 nits_35_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 5]);
    const int2 nits_25_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 6]);
    const int2 nits_18_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 7]);
    const int2 nits_10_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 8]);
    const int2 nits__5_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[ 9]);
    const int2 nits__2_50Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[10]);
    const int2 nits__1_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[11]);
#if (OVERWRITE_SDR_GAMMA == GAMMA_UNSET \
  || OVERWRITE_SDR_GAMMA == GAMMA_22    \
  || OVERWRITE_SDR_GAMMA == GAMMA_24)
    const int2 nits__0_25Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[12]);
#else
    const int2 nits__0_40Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[12]);
#endif
    const int2 nits__0_00Offset = Waveform::GetNitsOffset(waveDat.borderSize, waveDat.frameSize, waveDat.fontSpacer, waveDat.tickPoints[13]);

    const int2 text100_00Offset = nits100_00Offset - waveDat.textOffset;
    const int2 text_87_50Offset = nits_87_50Offset - waveDat.textOffset;
    const int2 text_75_00Offset = nits_75_00Offset - waveDat.textOffset;
    const int2 text_60_00Offset = nits_60_00Offset - waveDat.textOffset;
    const int2 text_50_00Offset = nits_50_00Offset - waveDat.textOffset;
    const int2 text_35_00Offset = nits_35_00Offset - waveDat.textOffset;
    const int2 text_25_00Offset = nits_25_00Offset - waveDat.textOffset;
    const int2 text_18_00Offset = nits_18_00Offset - waveDat.textOffset;
    const int2 text_10_00Offset = nits_10_00Offset - waveDat.textOffset;
    const int2 text__5_00Offset = nits__5_00Offset - waveDat.textOffset;
    const int2 text__2_50Offset = nits__2_50Offset - waveDat.textOffset;
    const int2 text__1_00Offset = nits__1_00Offset - waveDat.textOffset;
#if (OVERWRITE_SDR_GAMMA == GAMMA_UNSET \
  || OVERWRITE_SDR_GAMMA == GAMMA_22    \
  || OVERWRITE_SDR_GAMMA == GAMMA_24)
    const int2 text__0_25Offset = nits__0_25Offset - waveDat.textOffset;
#else
    const int2 text__0_40Offset = nits__0_40Offset - waveDat.textOffset;
#endif
    const int2 text__0_00Offset = nits__0_00Offset - waveDat.textOffset;

    const int2 charDimensionsForPercent = int2(waveDat.charDimensionXForPercent, waveDat.charDimensions.y);

    Waveform::DrawCharToScale(      _1_w, waveDat.charDimensions,   waveDat.atlasOffset, text100_00Offset, 0);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text100_00Offset, 1);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text100_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text100_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text100_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text100_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text100_00Offset, 6);

    Waveform::DrawCharToScale(      _8_w, waveDat.charDimensions,   waveDat.atlasOffset, text_87_50Offset, 1);
    Waveform::DrawCharToScale(      _7_w, waveDat.charDimensions,   waveDat.atlasOffset, text_87_50Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text_87_50Offset, 3);
    Waveform::DrawCharToScale(      _5_w, waveDat.charDimensions,   waveDat.atlasOffset, text_87_50Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_87_50Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text_87_50Offset, 6);

    Waveform::DrawCharToScale(      _7_w, waveDat.charDimensions,   waveDat.atlasOffset, text_75_00Offset, 1);
    Waveform::DrawCharToScale(      _5_w, waveDat.charDimensions,   waveDat.atlasOffset, text_75_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text_75_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_75_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_75_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text_75_00Offset, 6);

    Waveform::DrawCharToScale(      _6_w, waveDat.charDimensions,   waveDat.atlasOffset, text_60_00Offset, 1);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_60_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text_60_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_60_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_60_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text_60_00Offset, 6);

    Waveform::DrawCharToScale(      _5_w, waveDat.charDimensions,   waveDat.atlasOffset, text_50_00Offset, 1);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_50_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text_50_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_50_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_50_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text_50_00Offset, 6);

    Waveform::DrawCharToScale(      _3_w, waveDat.charDimensions,   waveDat.atlasOffset, text_35_00Offset, 1);
    Waveform::DrawCharToScale(      _5_w, waveDat.charDimensions,   waveDat.atlasOffset, text_35_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text_35_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_35_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_35_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text_35_00Offset, 6);

    Waveform::DrawCharToScale(      _2_w, waveDat.charDimensions,   waveDat.atlasOffset, text_25_00Offset, 1);
    Waveform::DrawCharToScale(      _5_w, waveDat.charDimensions,   waveDat.atlasOffset, text_25_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text_25_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_25_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_25_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text_25_00Offset, 6);

    Waveform::DrawCharToScale(      _1_w, waveDat.charDimensions,   waveDat.atlasOffset, text_18_00Offset, 1);
    Waveform::DrawCharToScale(      _8_w, waveDat.charDimensions,   waveDat.atlasOffset, text_18_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text_18_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_18_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_18_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text_18_00Offset, 6);

    Waveform::DrawCharToScale(      _1_w, waveDat.charDimensions,   waveDat.atlasOffset, text_10_00Offset, 1);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_10_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text_10_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_10_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text_10_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text_10_00Offset, 6);

    Waveform::DrawCharToScale(      _5_w, waveDat.charDimensions,   waveDat.atlasOffset, text__5_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text__5_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__5_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__5_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text__5_00Offset, 6);

    Waveform::DrawCharToScale(      _2_w, waveDat.charDimensions,   waveDat.atlasOffset, text__2_50Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text__2_50Offset, 3);
    Waveform::DrawCharToScale(      _5_w, waveDat.charDimensions,   waveDat.atlasOffset, text__2_50Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__2_50Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text__2_50Offset, 6);

    Waveform::DrawCharToScale(      _1_w, waveDat.charDimensions,   waveDat.atlasOffset, text__1_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text__1_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__1_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__1_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text__1_00Offset, 6);

#if (OVERWRITE_SDR_GAMMA == GAMMA_UNSET \
  || OVERWRITE_SDR_GAMMA == GAMMA_22    \
  || OVERWRITE_SDR_GAMMA == GAMMA_24)

    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_25Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_25Offset, 3);
    Waveform::DrawCharToScale(      _2_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_25Offset, 4);
    Waveform::DrawCharToScale(      _5_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_25Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text__0_25Offset, 6);
#else
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_40Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_40Offset, 3);
    Waveform::DrawCharToScale(      _4_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_40Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_40Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text__0_40Offset, 6);
#endif

    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_00Offset, 2);
    Waveform::DrawCharToScale(    _dot_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_00Offset, 3);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_00Offset, 4);
    Waveform::DrawCharToScale(      _0_w, waveDat.charDimensions,   waveDat.atlasOffset, text__0_00Offset, 5);
    Waveform::DrawCharToScale(_percent_w, charDimensionsForPercent, waveDat.atlasOffset, text__0_00Offset, 6);

#endif

    // draw the frame, ticks and horizontal lines
    for (int y = 0; y < waveDat.endXY.y; y++)
    {
      int2 curPos = waveDat.offsetToFrame + int2(0, y);

      float curGrey = lerp(0.5f, 0.4f, (float(y + WAVEDAT_CUTOFFSET) / float(waveDat.endYminus1 + WAVEDAT_CUTOFFSET)));
      curGrey = pow(curGrey, 2.2f);
      // using gamma 2 as intermediate gamma space
      curGrey = sqrt(curGrey);

      float4 curColour = float4(curGrey.xxx, 1.f);

      // draw top and bottom part of the frame
      if (y <  waveDat.frameSize
       || y >= waveDat.lowerFrameStart)
      {
        for (int x = 0; x < waveDat.endXY.x; x++)
        {
          int2 curXPos = int2(x + curPos.x, curPos.y);
          tex2Dstore(StorageLuminanceWaveformScale, curXPos, curColour);
        }
      }
      // draw left and right part of the frame
      else
      {
        for (int x = 0; x < waveDat.frameSize; x++)
        {
          int2 curLeftPos  = int2(x + curPos.x, curPos.y);
          int2 curRightPos = int2(curLeftPos.x + waveDat.waveformArea.x + waveDat.frameSize, curLeftPos.y);
          tex2Dstore(StorageLuminanceWaveformScale, curLeftPos,  curColour);
          tex2Dstore(StorageLuminanceWaveformScale, curRightPos, curColour);
        }
      }

      // draw top tick and bottom tick
#ifdef IS_HDR_CSP
  #ifdef IS_QHD_OR_HIGHER_RES
      if ((LUMINANCE_WAVEFORM_CUTOFF_POINT == 0 && ((nits10000_00Offset.y - 1) == curPos.y || nits10000_00Offset.y == curPos.y || (nits10000_00Offset.y + 1) == curPos.y))
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT == 1 && ((nits_4000_00Offset.y - 1) == curPos.y || nits_4000_00Offset.y == curPos.y || (nits_4000_00Offset.y + 1) == curPos.y))
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT == 2 && ((nits_2000_00Offset.y - 1) == curPos.y || nits_2000_00Offset.y == curPos.y || (nits_2000_00Offset.y + 1) == curPos.y))
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT == 3 && ((nits_1000_00Offset.y - 1) == curPos.y || nits_1000_00Offset.y == curPos.y || (nits_1000_00Offset.y + 1) == curPos.y))
       || (nits____0_00Offset.y - 1) == curPos.y || nits____0_00Offset.y == curPos.y || (nits____0_00Offset.y + 1) == curPos.y)
  #else
      if ((LUMINANCE_WAVEFORM_CUTOFF_POINT == 0 && nits10000_00Offset.y == curPos.y)
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT == 1 && nits_4000_00Offset.y == curPos.y)
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT == 2 && nits_2000_00Offset.y == curPos.y)
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT == 3 && nits_1000_00Offset.y == curPos.y)
       || nits____0_00Offset.y == curPos.y)
  #endif
#else
  #ifdef IS_QHD_OR_HIGHER_RES
      if ((nits100_00Offset.y - 1) == curPos.y || nits100_00Offset.y == curPos.y || (nits100_00Offset.y + 1) == curPos.y
       || (nits__0_00Offset.y - 1) == curPos.y || nits__0_00Offset.y == curPos.y || (nits__0_00Offset.y + 1) == curPos.y)
  #else
      if (nits100_00Offset.y == curPos.y
       || nits__0_00Offset.y == curPos.y)
  #endif
#endif
      {
        for (int x = waveDat.tickXOffset; x < (waveDat.tickXOffset + waveDat.frameSize); x++)
        {
          int2 curTickPos = int2(x, curPos.y);
          tex2Dstore(StorageLuminanceWaveformScale, curTickPos, curColour);
        }
      }

      // draw ticks + draw horizontal lines
#ifdef IS_HDR_CSP
  #ifdef IS_QHD_OR_HIGHER_RES
      if ((LUMINANCE_WAVEFORM_CUTOFF_POINT < 1 && ((nits_4000_00Offset.y - 1) == curPos.y || nits_4000_00Offset.y == curPos.y || (nits_4000_00Offset.y + 1) == curPos.y))
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT < 2 && ((nits_2000_00Offset.y - 1) == curPos.y || nits_2000_00Offset.y == curPos.y || (nits_2000_00Offset.y + 1) == curPos.y))
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT < 3 && ((nits_1000_00Offset.y - 1) == curPos.y || nits_1000_00Offset.y == curPos.y || (nits_1000_00Offset.y + 1) == curPos.y))
       || (nits__400_00Offset.y - 1) == curPos.y || nits__400_00Offset.y == curPos.y || (nits__400_00Offset.y + 1) == curPos.y
       || (nits__203_00Offset.y - 1) == curPos.y || nits__203_00Offset.y == curPos.y || (nits__203_00Offset.y + 1) == curPos.y
       || (nits__100_00Offset.y - 1) == curPos.y || nits__100_00Offset.y == curPos.y || (nits__100_00Offset.y + 1) == curPos.y
       || (nits___50_00Offset.y - 1) == curPos.y || nits___50_00Offset.y == curPos.y || (nits___50_00Offset.y + 1) == curPos.y
       || (nits___25_00Offset.y - 1) == curPos.y || nits___25_00Offset.y == curPos.y || (nits___25_00Offset.y + 1) == curPos.y
       || (nits___10_00Offset.y - 1) == curPos.y || nits___10_00Offset.y == curPos.y || (nits___10_00Offset.y + 1) == curPos.y
       || (nits____5_00Offset.y - 1) == curPos.y || nits____5_00Offset.y == curPos.y || (nits____5_00Offset.y + 1) == curPos.y
       || (nits____2_50Offset.y - 1) == curPos.y || nits____2_50Offset.y == curPos.y || (nits____2_50Offset.y + 1) == curPos.y
       || (nits____1_00Offset.y - 1) == curPos.y || nits____1_00Offset.y == curPos.y || (nits____1_00Offset.y + 1) == curPos.y
       || (nits____0_25Offset.y - 1) == curPos.y || nits____0_25Offset.y == curPos.y || (nits____0_25Offset.y + 1) == curPos.y
       || (nits____0_05Offset.y - 1) == curPos.y || nits____0_05Offset.y == curPos.y || (nits____0_05Offset.y + 1) == curPos.y)
  #else
      if ((LUMINANCE_WAVEFORM_CUTOFF_POINT < 1 && nits_4000_00Offset.y == curPos.y)
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT < 2 && nits_2000_00Offset.y == curPos.y)
       || (LUMINANCE_WAVEFORM_CUTOFF_POINT < 3 && nits_1000_00Offset.y == curPos.y)
       || nits__400_00Offset.y == curPos.y
       || nits__203_00Offset.y == curPos.y
       || nits__100_00Offset.y == curPos.y
       || nits___50_00Offset.y == curPos.y
       || nits___25_00Offset.y == curPos.y
       || nits___10_00Offset.y == curPos.y
       || nits____5_00Offset.y == curPos.y
       || nits____2_50Offset.y == curPos.y
       || nits____1_00Offset.y == curPos.y
       || nits____0_25Offset.y == curPos.y
       || nits____0_05Offset.y == curPos.y)
  #endif
#else
  #ifdef IS_QHD_OR_HIGHER_RES
      if ((nits_87_50Offset.y - 1) == curPos.y || nits_87_50Offset.y == curPos.y || (nits_87_50Offset.y + 1) == curPos.y
       || (nits_75_00Offset.y - 1) == curPos.y || nits_75_00Offset.y == curPos.y || (nits_75_00Offset.y + 1) == curPos.y
       || (nits_60_00Offset.y - 1) == curPos.y || nits_60_00Offset.y == curPos.y || (nits_60_00Offset.y + 1) == curPos.y
       || (nits_50_00Offset.y - 1) == curPos.y || nits_50_00Offset.y == curPos.y || (nits_50_00Offset.y + 1) == curPos.y
       || (nits_35_00Offset.y - 1) == curPos.y || nits_35_00Offset.y == curPos.y || (nits_35_00Offset.y + 1) == curPos.y
       || (nits_25_00Offset.y - 1) == curPos.y || nits_25_00Offset.y == curPos.y || (nits_25_00Offset.y + 1) == curPos.y
       || (nits_18_00Offset.y - 1) == curPos.y || nits_18_00Offset.y == curPos.y || (nits_18_00Offset.y + 1) == curPos.y
       || (nits_10_00Offset.y - 1) == curPos.y || nits_10_00Offset.y == curPos.y || (nits_10_00Offset.y + 1) == curPos.y
       || (nits__5_00Offset.y - 1) == curPos.y || nits__5_00Offset.y == curPos.y || (nits__5_00Offset.y + 1) == curPos.y
       || (nits__2_50Offset.y - 1) == curPos.y || nits__2_50Offset.y == curPos.y || (nits__2_50Offset.y + 1) == curPos.y
       || (nits__1_00Offset.y - 1) == curPos.y || nits__1_00Offset.y == curPos.y || (nits__1_00Offset.y + 1) == curPos.y
    #if (OVERWRITE_SDR_GAMMA == GAMMA_UNSET \
      || OVERWRITE_SDR_GAMMA == GAMMA_22    \
      || OVERWRITE_SDR_GAMMA == GAMMA_24)
       || (nits__0_25Offset.y - 1) == curPos.y || nits__0_25Offset.y == curPos.y || (nits__0_25Offset.y + 1) == curPos.y
    #else
       || (nits__0_40Offset.y - 1) == curPos.y || nits__0_40Offset.y == curPos.y || (nits__0_40Offset.y + 1) == curPos.y
    #endif
      )
  #else
      if (nits_87_50Offset.y == curPos.y
       || nits_75_00Offset.y == curPos.y
       || nits_60_00Offset.y == curPos.y
       || nits_50_00Offset.y == curPos.y
       || nits_35_00Offset.y == curPos.y
       || nits_25_00Offset.y == curPos.y
       || nits_18_00Offset.y == curPos.y
       || nits_10_00Offset.y == curPos.y
       || nits__5_00Offset.y == curPos.y
       || nits__2_50Offset.y == curPos.y
       || nits__1_00Offset.y == curPos.y
    #if (OVERWRITE_SDR_GAMMA == GAMMA_UNSET \
      || OVERWRITE_SDR_GAMMA == GAMMA_22    \
      || OVERWRITE_SDR_GAMMA == GAMMA_24)
       || nits__0_25Offset.y == curPos.y
    #else
       || nits__0_40Offset.y == curPos.y
    #endif
      )
  #endif
#endif
      {
        for (int x = waveDat.tickXOffset; x < (waveDat.tickXOffset + waveDat.endXY.x); x++)
        {
          int2 curTickPos = int2(x, curPos.y);
          tex2Dstore(StorageLuminanceWaveformScale, curTickPos, curColour);
        }
      }
    }

    tex2Dstore(StorageConsolidated, COORDS_LUMINANCE_WAVEFORM_LAST_SIZE_X,       _LUMINANCE_WAVEFORM_SIZE.x);
    tex2Dstore(StorageConsolidated, COORDS_LUMINANCE_WAVEFORM_LAST_SIZE_Y,       _LUMINANCE_WAVEFORM_SIZE.y);
#ifdef IS_HDR_CSP
    tex2Dstore(StorageConsolidated, COORDS_LUMINANCE_WAVEFORM_LAST_CUTOFF_POINT, LUMINANCE_WAVEFORM_CUTOFF_POINT);
#endif
  }
  return;
}

void PS_ClearLuminanceWaveformTexture(
  in  float4 VPos : SV_Position,
  out float4 Out  : SV_Target0)
{
  Out = 0.f;
  discard;
}


// 8 * 4
#if ((BUFFER_WIDTH % 32) == 0)
  #define RENDER_WAVEFORM_DISPATCH_X (BUFFER_WIDTH / 32)
#else
  #define RENDER_WAVEFORM_X_NEEDS_CLAMPING
  #define RENDER_WAVEFORM_DISPATCH_X (BUFFER_WIDTH / 32 + 1)
#endif

#if ((BUFFER_HEIGHT % 32) == 0)
  #define RENDER_WAVEFORM_DISPATCH_Y (BUFFER_HEIGHT / 32)
#else
  #define RENDER_WAVEFORM_Y_NEEDS_CLAMPING
  #define RENDER_WAVEFORM_DISPATCH_Y (BUFFER_HEIGHT / 32 + 1)
#endif


void CS_RenderLuminanceWaveform(uint3 DTID : SV_DispatchThreadID)
{
  if (_SHOW_LUMINANCE_WAVEFORM)
  {

    const int xStart = DTID.x * 4;
#ifndef RENDER_WAVEFORM_X_NEEDS_CLAMPING
    const int xStop  = xStart + 4;
#else
    const int xStop  = min(xStart + 4, BUFFER_WIDTH);
#endif

    const int yStart = DTID.y * 4;
#ifndef RENDER_WAVEFORM_Y_NEEDS_CLAMPING
    const int yStop  = yStart + 4;
#else
    const int yStop  = min(yStart + 4, BUFFER_HEIGHT);
#endif

    for (int x = xStart; x < xStop; x++)
    {
      for (int y = yStart; y < yStop; y++)
      {
        float curPixelNits = tex2Dfetch(StorageNitsValues, int2(x, y));

        if (curPixelNits > 0.f)
        {
#ifdef IS_HDR_CSP
          float encodedPixel = Csp::Trc::NitsTo::Pq(curPixelNits);
#elif (ACTUAL_COLOUR_SPACE == CSP_SRGB)
          float encodedPixel = ENCODE_SDR(curPixelNits / 100.f);
#endif

          int2 coord = float2(float(x)
                            / TEXTURE_LUMINANCE_WAVEFORM_BUFFER_WIDTH_FACTOR,
                              float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT)
                            - (encodedPixel * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT))) + 0.5f;

          float3 waveformColour = WaveformRgbValues(curPixelNits);
          waveformColour = sqrt(waveformColour);

          tex2Dstore(StorageLuminanceWaveform,
                     coord,
                     float4(waveformColour, 1.f));
        }
      }
    }
  }
}


// Vertex shader generating a triangle covering the entire screen.
// Calculate values only "once" (3 times because it's 3 vertices)
// for the pixel shader.
void VS_PrepareRenderLuminanceWaveformToScale(
  in                  uint   Id       : SV_VertexID,
  out                 float4 VPos     : SV_Position,
  out                 float2 TexCoord : TEXCOORD0,
  out nointerpolation int4   WaveDat0 : WaveDat0,
#ifdef IS_HDR_CSP
  out nointerpolation int3   WaveDat1 : WaveDat1
#else
  out nointerpolation int2   WaveDat1 : WaveDat1
#endif
  )
{
  TexCoord.x = (Id == 2) ? 2.f
                         : 0.f;
  TexCoord.y = (Id == 1) ? 2.f
                         : 0.f;
  VPos = float4(TexCoord * float2(2.f, -2.f) + float2(-1.f, 1.f), 0.f, 1.f);

#define WaveformActiveArea   WaveDat0.xy
#define OffsetToWaveformArea WaveDat0.zw

#define MinNitsLineY WaveDat1.x
#define MaxNitsLineY WaveDat1.y

  WaveDat0     =  0;
  MinNitsLineY =  INT_MAX;
  MaxNitsLineY = -INT_MAX;

#ifdef IS_HDR_CSP
  #define WaveformCutoffOffset WaveDat1.z

  WaveformCutoffOffset = 0;
#else
  #define WaveformCutoffOffset 0
#endif

  if (_SHOW_LUMINANCE_WAVEFORM)
  {
    Waveform::SWaveformData waveDat = Waveform::GetData();

    WaveformActiveArea = waveDat.waveformArea;

    OffsetToWaveformArea = waveDat.offsetToFrame
                         + waveDat.frameSize;

#ifdef IS_HDR_CSP
    WaveformCutoffOffset = WAVEDAT_CUTOFFSET;
#endif

    const float waveformScaleFactorY = clamp(_LUMINANCE_WAVEFORM_SIZE.y / 100.f, 0.5f, 2.f);

    if (_LUMINANCE_WAVEFORM_SHOW_MIN_NITS_LINE)
    {
      const float minNits = tex2Dfetch(SamplerConsolidated, COORDS_MIN_NITS_VALUE);

#ifdef IS_HDR_CSP
  #define MAX_NITS_LINE_CUTOFF 10000.f
#else
  #define MAX_NITS_LINE_CUTOFF 100.f
#endif

      if (minNits > 0.f
       && minNits < MAX_NITS_LINE_CUTOFF)
      {
#ifdef IS_HDR_CSP
        float encodedMinNits = Csp::Trc::NitsTo::Pq(minNits);
#else
        float encodedMinNits = ENCODE_SDR(minNits / 100.f);
#endif
        MinNitsLineY =
          int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT)
             - (encodedMinNits * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT)))
            * waveformScaleFactorY + 0.5f)
        - WAVEDAT_CUTOFFSET;
      }
    }

    if (_LUMINANCE_WAVEFORM_SHOW_MAX_NITS_LINE)
    {
      const float maxNits = tex2Dfetch(SamplerConsolidated, COORDS_MAX_NITS_VALUE);

      if (maxNits >  0.f
       && maxNits < MAX_NITS_LINE_CUTOFF)
      {
#ifdef IS_HDR_CSP
        float encodedMaxNits = Csp::Trc::NitsTo::Pq(maxNits);
#else
        float encodedMaxNits = ENCODE_SDR(maxNits / 100.f);
#endif
        MaxNitsLineY =
          int((float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT)
             - (encodedMaxNits * float(TEXTURE_LUMINANCE_WAVEFORM_USED_HEIGHT)))
            * waveformScaleFactorY + 0.5f)
        - WAVEDAT_CUTOFFSET;
      }
    }
  }
}

void PS_RenderLuminanceWaveformToScale(
  in                  float4 VPos     : SV_Position,
  in                  float2 TexCoord : TEXCOORD0,
  in  nointerpolation int4   WaveDat0 : WaveDat0,
#ifdef IS_HDR_CSP
  in  nointerpolation int3   WaveDat1 : WaveDat1,
#else
  in  nointerpolation int2   WaveDat1 : WaveDat1,
#endif
  out                 float4 Out      : SV_Target0)
{
  Out = 0.f;

  if (_SHOW_LUMINANCE_WAVEFORM)
  {
    const int2 pureCoordAsInt = int2(VPos.xy);

    int2 waveformCoords = pureCoordAsInt - OffsetToWaveformArea;

    if (all(waveformCoords >= 0)
     && all(waveformCoords < WaveformActiveArea))
    {
#ifdef IS_QHD_OR_HIGHER_RES
      if (waveformCoords.y == MinNitsLineY
       || waveformCoords.y == MinNitsLineY - 1)
#else
      if (waveformCoords.y == MinNitsLineY)
#endif
      {
        Out = float4(1.f, 1.f, 1.f, 1.f);
        return;
      }
#ifdef IS_QHD_OR_HIGHER_RES
      if (waveformCoords.y == MaxNitsLineY
       || waveformCoords.y == MaxNitsLineY + 1)
#else
      if (waveformCoords.y == MaxNitsLineY)
#endif
      {
        Out = float4(1.f, 1.f, 0.f, 1.f);
        return;
      }
      const bool waveformCoordsGTEMaxNitsLine = waveformCoords.y >= MaxNitsLineY;
      const bool waveformCoordsSTEMinNitsLine = waveformCoords.y <= MinNitsLineY;

      const bool showMaxNitsLineActive = waveformCoordsGTEMaxNitsLine && _LUMINANCE_WAVEFORM_SHOW_MAX_NITS_LINE;
      const bool showMinNitsLineActive = waveformCoordsSTEMinNitsLine && _LUMINANCE_WAVEFORM_SHOW_MIN_NITS_LINE;

      if (( showMaxNitsLineActive                  &&  showMinNitsLineActive)
       || (!_LUMINANCE_WAVEFORM_SHOW_MAX_NITS_LINE &&  showMinNitsLineActive)
       || ( showMaxNitsLineActive                  && !_LUMINANCE_WAVEFORM_SHOW_MIN_NITS_LINE)
       || (!_LUMINANCE_WAVEFORM_SHOW_MAX_NITS_LINE && !_LUMINANCE_WAVEFORM_SHOW_MIN_NITS_LINE))
      {
        float2 waveformSamplerCoords = (float2(waveformCoords + int2(0, WaveformCutoffOffset)) + 0.5f)
                                      * (clamp(100.f / _LUMINANCE_WAVEFORM_SIZE, float2(1.f, 0.5f), 2.f))
                                      / float2(TEXTURE_LUMINANCE_WAVEFORM_WIDTH - 1, TEXTURE_LUMINANCE_WAVEFORM_HEIGHT - 1);

        float4 scaleColour = tex2Dfetch(SamplerLuminanceWaveformScale, pureCoordAsInt);
        // using gamma 2 as intermediate gamma space
        scaleColour.rgb *= scaleColour.rgb;

        float4 waveformColour = tex2D(SamplerLuminanceWaveform, waveformSamplerCoords);
        // using gamma 2 as intermediate gamma space
        waveformColour.rgb *= waveformColour.rgb;

        Out = scaleColour
            + waveformColour;

        // using gamma 2 as intermediate gamma space
        Out.rgb = sqrt(Out.rgb);
        return;
      }
    }
    //else
    Out = tex2Dfetch(SamplerLuminanceWaveformScale, pureCoordAsInt);
    return;
  }
  discard;
}

#endif //ANALYSIS_ENABLE

void PS_CalcNitsPerPixel(
              float4 VPos     : SV_Position,
              float2 TexCoord : TEXCOORD0,
  out precise float  CurNits  : SV_Target0)
{
  CurNits = 0.f;

#if defined(ANALYSIS_ENABLE)
  if (_SHOW_NITS_VALUES
   || _SHOW_NITS_FROM_CURSOR
   || _SHOW_HEATMAP
   || _SHOW_LUMINANCE_WAVEFORM
   || _HIGHLIGHT_NIT_RANGE
   || _DRAW_ABOVE_NITS_AS_BLACK
   || _DRAW_BELOW_NITS_AS_BLACK
#ifdef IS_HDR_CSP
   || SHOW_CSP_MAP
#endif
  )
  {
#endif //ANALYSIS_ENABLE

    precise const float3 pixel = tex2Dfetch(ReShade::BackBuffer, int2(VPos.xy)).rgb;

#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB)

    precise float curPixelNits = dot(Csp::Mat::Bt709ToXYZ[1], pixel) * 80.f;

#elif (ACTUAL_COLOUR_SPACE == CSP_HDR10)

    precise float curPixelNits = dot(Csp::Mat::Bt2020ToXYZ[1], Csp::Trc::PqTo::Nits(pixel));

#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)

    precise float curPixelNits = dot(Csp::Mat::Bt2020ToXYZ[1], Csp::Trc::HlgTo::Nits(pixel));

#elif (ACTUAL_COLOUR_SPACE == CSP_PS5)

    precise float curPixelNits = dot(Csp::Mat::Bt2020ToXYZ[1], pixel) * 100.f;

#elif (ACTUAL_COLOUR_SPACE == CSP_SRGB)

    precise float curPixelNits = dot(Csp::Mat::Bt709ToXYZ[1], DECODE_SDR(pixel)) * 100.f;

#else

    float curPixelNits = 0.f;

#endif //ACTUAL_COLOUR_SPACE ==

    if (curPixelNits > 0.f)
    {
      CurNits = curPixelNits;
    }
    return;

#if defined(ANALYSIS_ENABLE)
  }
  discard;
#endif //ANALYSIS_ENABLE
}

#if defined(ANALYSIS_ENABLE)

#define COORDS_INTERMEDIATE_MAX_NITS(X) \
  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 0 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)
//#define COORDS_INTERMEDIATE_AVG_NITS(X) \
//  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 1 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)
//#define COORDS_INTERMEDIATE_MIN_NITS(X) \
//  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 2 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)
//
// per column first
//void CS_GetMaxAvgMinCll0(uint3 ID : SV_DispatchThreadID)
//{
//  if (_SHOW_NITS_VALUES)
//  {
//#ifndef WIDTH1_DISPATCH_DOESNT_OVERFLOW
//
//  if (ID.x < BUFFER_WIDTH)
//  {
//
//#endif
//
//    float maxNits = 0.f;
//    float avgNits = 0.f;
//    float minNits = 65504.f;
//
//    for (uint y = 0; y < BUFFER_HEIGHT; y++)
//    {
//      float curNits = tex2Dfetch(StorageNitsValues, int2(ID.x, y));
//
//      if (curNits > maxNits)
//        maxNits = curNits;
//
//      avgNits += curNits;
//
//      if (curNits < minNits)
//        minNits = curNits;
//    }
//
//    avgNits /= BUFFER_HEIGHT;
//
//    tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS(ID.x), maxNits);
//    tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_AVG_NITS(ID.x), avgNits);
//    tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MIN_NITS(ID.x), minNits);
//
//#ifndef WIDTH1_DISPATCH_DOESNT_OVERFLOW
//
//  }
//
//#endif
//  }
//}
//
//void CS_GetMaxAvgMinCll1(uint3 ID : SV_DispatchThreadID)
//{
//  if (_SHOW_NITS_VALUES)
//  {
//  float maxNits = 0.f;
//  float avgNits = 0.f;
//  float minNits = 65504.f;
//
//  for (uint x = 0; x < BUFFER_WIDTH; x++)
//  {
//    float curMaxNits = tex2Dfetch(StorageConsolidated, int2(COORDS_INTERMEDIATE_MAX_NITS(x)));
//    float curAvgNits = tex2Dfetch(StorageConsolidated, int2(COORDS_INTERMEDIATE_AVG_NITS(x)));
//    float curMinNits = tex2Dfetch(StorageConsolidated, int2(COORDS_INTERMEDIATE_MIN_NITS(x)));
//
//    if (curMaxNits > maxNits)
//      maxNits = curMaxNits;
//
//    avgNits += curAvgNits;
//
//    if (curMinNits < minNits)
//      minNits = curMinNits;
//  }
//
//  avgNits /= BUFFER_WIDTH;
//
//  barrier();
//
//  tex2Dstore(StorageConsolidated, COORDS_MAX_NITS_VALUE, maxNits);
//  tex2Dstore(StorageConsolidated, COORDS_AVG_NITS_VALUE, avgNits);
//  tex2Dstore(StorageConsolidated, COORDS_MIN_NITS_VALUE, minNits);
//  }
//}
//
//
// per column first
//void CS_GetMaxCll0(uint3 ID : SV_DispatchThreadID)
//{
//#ifndef WIDTH1_DISPATCH_DOESNT_OVERFLOW
//
//  if (ID.x < BUFFER_WIDTH)
//  {
//
//#endif
//
//    float maxNits = 0.f;
//
//    for (uint y = 0; y < BUFFER_HEIGHT; y++)
//    {
//      float curNits = tex2Dfetch(StorageNitsValues, int2(ID.x, y));
//
//      if (curNits > maxNits)
//        maxNits = curNits;
//    }
//
//    tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS(ID.x), maxNits);
//
//#ifndef WIDTH1_DISPATCH_DOESNT_OVERFLOW
//
//  }
//
//#endif
//}
//
//void CS_GetMaxCll1(uint3 ID : SV_DispatchThreadID)
//{
//  float maxNits = 0.f;
//
//  for (uint x = 0; x < BUFFER_WIDTH; x++)
//  {
//    float curNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS(x));
//
//    if (curNits > maxNits)
//      maxNits = curNits;
//  }
//
//  barrier();
//
//  tex2Dstore(StorageConsolidated, COORDS_MAX_NITS_VALUE, maxNits);
//}
//
//#undef COORDS_INTERMEDIATE_MAX_NITS
//#undef COORDS_INTERMEDIATE_AVG_NITS
//#undef COORDS_INTERMEDIATE_MIN_NITS

#endif //ANALYSIS_ENABLE

#define COORDS_INTERMEDIATE_MAX_NITS0(X) \
  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 0 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)
#define COORDS_INTERMEDIATE_AVG_NITS0(X) \
  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 1 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)
#define COORDS_INTERMEDIATE_MIN_NITS0(X) \
  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 2 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)
#define COORDS_INTERMEDIATE_MAX_NITS1(X) \
  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 3 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)
#define COORDS_INTERMEDIATE_AVG_NITS1(X) \
  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 4 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)
#define COORDS_INTERMEDIATE_MIN_NITS1(X) \
  int2(X + INTERMEDIATE_NITS_VALUES_X_OFFSET, 5 + INTERMEDIATE_NITS_VALUES_Y_OFFSET)

#if defined(ANALYSIS_ENABLE)

void CS_GetMaxAvgMinNits0_NEW(uint3 ID : SV_DispatchThreadID)
{
  if (_SHOW_NITS_VALUES
   || (_SHOW_LUMINANCE_WAVEFORM
    && (_LUMINANCE_WAVEFORM_SHOW_MIN_NITS_LINE || _LUMINANCE_WAVEFORM_SHOW_MAX_NITS_LINE)))
  {
#ifndef WIDTH1_DISPATCH_DOESNT_OVERFLOW

    if (ID.x < BUFFER_WIDTH)
    {

#endif

      if(ID.y == 0)
      {
        float maxNits = 0.f;
        float avgNits = 0.f;
        float minNits = FP32_MAX;

        for (uint y = 0; y < HEIGHT0; y++)
        {
          const float curNits = tex2Dfetch(StorageNitsValues, int2(ID.x, y));

          maxNits = max(maxNits, curNits);

          avgNits += curNits;

          minNits = min(minNits, curNits);
        }

        avgNits /= HEIGHT0;

        tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS0(ID.x), maxNits);
        tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_AVG_NITS0(ID.x), avgNits);
        tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MIN_NITS0(ID.x), minNits);

        barrier();
      }
      else
      {
        float maxNits = 0.f;
        float avgNits = 0.f;
        float minNits = FP32_MAX;

        for (uint y = HEIGHT0; y < BUFFER_HEIGHT; y++)
        {
          const float curNits = tex2Dfetch(StorageNitsValues, int2(ID.x, y));

          maxNits = max(maxNits, curNits);

          avgNits += curNits;

          minNits = min(minNits, curNits);
        }

        avgNits /= HEIGHT1;

        tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS1(ID.x), maxNits);
        tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_AVG_NITS1(ID.x), avgNits);
        tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MIN_NITS1(ID.x), minNits);

        barrier();
      }

#ifndef WIDTH1_DISPATCH_DOESNT_OVERFLOW

    }

#endif
  }
}

void CS_GetMaxAvgMinNits1_NEW(uint3 ID : SV_DispatchThreadID)
{
  if (_SHOW_NITS_VALUES
   || (_SHOW_LUMINANCE_WAVEFORM
    && (_LUMINANCE_WAVEFORM_SHOW_MIN_NITS_LINE || _LUMINANCE_WAVEFORM_SHOW_MAX_NITS_LINE)))
  {
    if (ID.x == 0)
    {
      if (ID.y == 0)
      {
        float maxNits = 0.f;
        float avgNits = 0.f;
        float minNits = FP32_MAX;

        for(uint x = 0; x < WIDTH0; x++)
        {
          const float curMaxNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS0(x));
          const float curAvgNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_AVG_NITS0(x));
          const float curMinNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MIN_NITS0(x));

          maxNits = max(maxNits, curMaxNits);

          avgNits += curAvgNits;

          minNits = min(minNits, curMinNits);
        }

        avgNits /= WIDTH0;

        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE0, maxNits);
        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_AVG_NITS_VALUE0, avgNits);
        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MIN_NITS_VALUE0, minNits);

        barrier();

        return;
      }
      else
      {
        float maxNits = 0.f;
        float avgNits = 0.f;
        float minNits = FP32_MAX;

        for(uint x = 0; x < WIDTH0; x++)
        {
          const float curMaxNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS1(x));
          const float curAvgNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_AVG_NITS1(x));
          const float curMinNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MIN_NITS1(x));

          maxNits = max(maxNits, curMaxNits);

          avgNits += curAvgNits;

          minNits = min(minNits, curMinNits);
        }

        avgNits /= WIDTH0;

        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE1, maxNits);
        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_AVG_NITS_VALUE1, avgNits);
        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MIN_NITS_VALUE1, minNits);

        barrier();

        return;
      }
    }
    else
    {
      if (ID.y == 0)
      {
        float maxNits = 0.f;
        float avgNits = 0.f;
        float minNits = FP32_MAX;

        for(uint x = WIDTH0; x < BUFFER_WIDTH; x++)
        {
          const float curMaxNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS0(x));
          const float curAvgNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_AVG_NITS0(x));
          const float curMinNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MIN_NITS0(x));

          maxNits = max(maxNits, curMaxNits);

          avgNits += curAvgNits;

          minNits = min(minNits, curMinNits);
        }

        avgNits /= WIDTH1;

        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE2, maxNits);
        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_AVG_NITS_VALUE2, avgNits);
        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MIN_NITS_VALUE2, minNits);

        barrier();

        return;
      }
      else
      {
        float maxNits = 0.f;
        float avgNits = 0.f;
        float minNits = FP32_MAX;

        for(uint x = WIDTH0; x < BUFFER_WIDTH; x++)
        {
          const float curMaxNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS1(x));
          const float curAvgNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_AVG_NITS1(x));
          const float curMinNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MIN_NITS1(x));

          maxNits = max(maxNits, curMaxNits);

          avgNits += curAvgNits;

          minNits = min(minNits, curMinNits);
        }

        avgNits /= WIDTH1;

        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE3, maxNits);
        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_AVG_NITS_VALUE3, avgNits);
        tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MIN_NITS_VALUE3, minNits);

        barrier();

        return;
      }
    }
  }
}

void CS_GetFinalMaxAvgMinNits_NEW(uint3 ID : SV_DispatchThreadID)
{
  if (_SHOW_NITS_VALUES
   || (_SHOW_LUMINANCE_WAVEFORM
    && (_LUMINANCE_WAVEFORM_SHOW_MIN_NITS_LINE || _LUMINANCE_WAVEFORM_SHOW_MAX_NITS_LINE)))
  {
    const float maxNits0 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE0);
    const float maxNits1 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE1);
    const float maxNits2 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE2);
    const float maxNits3 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE3);

    const float maxNits = max(max(max(maxNits0, maxNits1), maxNits2), maxNits3);


    const float avgNits0 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_AVG_NITS_VALUE0);
    const float avgNits1 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_AVG_NITS_VALUE1);
    const float avgNits2 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_AVG_NITS_VALUE2);
    const float avgNits3 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_AVG_NITS_VALUE3);

    const float avgNits = (avgNits0 + avgNits1 + avgNits2 + avgNits3) / 4.f;


    const float minNits0 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MIN_NITS_VALUE0);
    const float minNits1 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MIN_NITS_VALUE1);
    const float minNits2 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MIN_NITS_VALUE2);
    const float minNits3 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MIN_NITS_VALUE3);

    const float minNits = min(min(min(minNits0, minNits1), minNits2), minNits3);

    tex2Dstore(StorageConsolidated, COORDS_MAX_NITS_VALUE, maxNits);
    tex2Dstore(StorageConsolidated, COORDS_AVG_NITS_VALUE, avgNits);
    tex2Dstore(StorageConsolidated, COORDS_MIN_NITS_VALUE, minNits);

    barrier();
  }
}

#endif //ANALYSIS_ENABLE

void CS_GetMaxNits0_NEW(uint3 ID : SV_DispatchThreadID)
{
#ifndef WIDTH1_DISPATCH_DOESNT_OVERFLOW

  if (ID.x < BUFFER_WIDTH)
  {

#endif

    if(ID.y == 0)
    {
      float maxNits = 0.f;

      for (uint y = 0; y < HEIGHT0; y++)
      {
        const float curNits = tex2Dfetch(StorageNitsValues, int2(ID.x, y));

        maxNits = max(maxNits, curNits);
      }

      tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS0(ID.x), maxNits);

      barrier();
    }
    else
    {
      float maxNits = 0.f;

      for (uint y = HEIGHT0; y < BUFFER_HEIGHT; y++)
      {
        const float curNits = tex2Dfetch(StorageNitsValues, int2(ID.x, y));

        maxNits = max(maxNits, curNits);
      }

      tex2Dstore(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS1(ID.x), maxNits);

      barrier();
    }

#ifndef WIDTH1_DISPATCH_DOESNT_OVERFLOW

  }

#endif
}

void CS_GetMaxNits1_NEW(uint3 ID : SV_DispatchThreadID)
{
  if (ID.x == 0)
  {
    if (ID.y == 0)
    {
      float maxNits = 0.f;

      for(uint x = 0; x < WIDTH0; x++)
      {
        const float curMaxNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS0(x));

        maxNits = max(maxNits, curMaxNits);
      }

      tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE0, maxNits);

      barrier();
    }
    else
    {
      float maxNits = 0.f;

      for(uint x = 0; x < WIDTH0; x++)
      {
        const float curMaxNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS1(x));

        maxNits = max(maxNits, curMaxNits);
      }

      tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE1, maxNits);

      barrier();
    }
  }
  else
  {
    if (ID.y == 0)
    {
      float maxNits = 0.f;

      for(uint x = WIDTH0; x < BUFFER_WIDTH; x++)
      {
        const float curMaxNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS0(x));

        maxNits = max(maxNits, curMaxNits);
      }

      tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE2, maxNits);

      barrier();
    }
    else
    {
      float maxNits = 0.f;

      for(uint x = WIDTH0; x < BUFFER_WIDTH; x++)
      {
        const float curMaxNits = tex2Dfetch(StorageConsolidated, COORDS_INTERMEDIATE_MAX_NITS1(x));

        maxNits = max(maxNits, curMaxNits);
      }

      tex2Dstore(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE3, maxNits);

      barrier();
    }
  }
}

void CS_GetFinalMaxNits_NEW(uint3 ID : SV_DispatchThreadID)
{
  const float maxNits0 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE0);
  const float maxNits1 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE1);
  const float maxNits2 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE2);
  const float maxNits3 = tex2Dfetch(StorageConsolidated, COORDS_FINAL_4_MAX_NITS_VALUE3);

  const float maxNits = max(max(max(maxNits0, maxNits1), maxNits2), maxNits3);

  tex2Dstore(StorageConsolidated, COORDS_MAX_NITS_VALUE, maxNits);

  barrier();
}


#undef COORDS_INTERMEDIATE_MAX_NITS0
#undef COORDS_INTERMEDIATE_AVG_NITS0
#undef COORDS_INTERMEDIATE_MIN_NITS0
#undef COORDS_INTERMEDIATE_MAX_NITS1
#undef COORDS_INTERMEDIATE_AVG_NITS1
#undef COORDS_INTERMEDIATE_MIN_NITS1

#if defined(ANALYSIS_ENABLE)

// per column first
//void CS_GetAvgCll0(uint3 ID : SV_DispatchThreadID)
//{
//  if (ID.x < BUFFER_WIDTH)
//  {
//    float avgNits = 0.f;
//
//    for(uint y = 0; y < BUFFER_HEIGHT; y++)
//    {
//      float curNits = tex2Dfetch(StorageNitsValues, int2(ID.x, y));
//
//      avgNits += curNits;
//    }
//
//    avgNits /= BUFFER_HEIGHT;
//
//    tex2Dstore(Storage_Intermediate_CLL_Values, int2(ID.x, 1), avgNits);
//  }
//}
//
//void CS_GetAvgCll1(uint3 ID : SV_DispatchThreadID)
//{
//  float avgNits = 0.f;
//
//  for(uint x = 0; x < BUFFER_WIDTH; x++)
//  {
//    float curNits = tex2Dfetch(Sampler_Intermediate_CLL_Values, int2(x, 1));
//
//    avgNits += curNits;
//  }
//
//  avgNits /= BUFFER_WIDTH;
//
//  tex2Dstore(Storage_Max_Avg_Min_CLL_Values, int2(1, 0), avgNits);
//}
//
//
//// per column first
//void CS_GetMinCll0(uint3 ID : SV_DispatchThreadID)
//{
//  if (ID.x < BUFFER_WIDTH)
//  {
//    float minNits = 65504.f;
//
//    for(uint y = 0; y < BUFFER_HEIGHT; y++)
//    {
//      float curNits = tex2Dfetch(StorageNitsValues, int2(ID.x, y));
//
//      if (curNits < minNits)
//        minNits = curNits;
//    }
//
//    tex2Dstore(Storage_Intermediate_CLL_Values, int2(ID.x, 2), minNits);
//  }
//}
//
//void CS_GetMinCll1(uint3 ID : SV_DispatchThreadID)
//{
//  float minNits = 65504.f;
//
//  for(uint x = 0; x < BUFFER_WIDTH; x++)
//  {
//    float curNits = tex2Dfetch(Sampler_Intermediate_CLL_Values, int2(x, 2));
//
//    if (curNits < minNits)
//      minNits = curNits;
//  }
//
//  tex2Dstore(Storage_Max_Avg_Min_CLL_Values, int2(2, 0), minNits);
//}


float3 FetchCspOutline(
  const int OutlineTextureOffset,
  const int CieBgWidth,
  const int VPosXAsInt,
  const int FetchPosY) // already calculated
{
  int2 fetchPos =
    int2(VPosXAsInt + (CieBgWidth * OutlineTextureOffset),
         FetchPosY);

  float3 fetchedPixel = tex2Dfetch(SamplerCieConsolidated, fetchPos).rgb;

  // using gamma 2 as intermediate gamma space
  return fetchedPixel * fetchedPixel;
}

// copy over clean bg and the outlines first every time
void PS_CopyCieBgAndOutlines(
  in  float4 VPos     : SV_Position,
  in  float2 TexCoord : TEXCOORD0,
  out float4 Out      : SV_Target0)
{
  int2 vPosAsInt2 = int2(VPos.xy);

  int2 fetchPos = int2(vPosAsInt2.x + CIE_BG_WIDTH_AS_INT[_CIE_DIAGRAM_TYPE] * int(CIE_TEXTURE_ENTRY_DIAGRAM_BLACK_BG),
                       vPosAsInt2.y + int(CIE_1931_BG_HEIGHT)               * int(_CIE_DIAGRAM_TYPE));

  Out = tex2Dfetch(SamplerCieConsolidated, fetchPos);

  // using gamma 2 as intermediate gamma space
  Out.rgb *= Out.rgb;

  if (_SHOW_CIE_CSP_BT709_OUTLINE)
  {
    float3 fetchedPixel = FetchCspOutline(int(CIE_TEXTURE_ENTRY_BT709_OUTLINE),
                                          CIE_BG_WIDTH_AS_INT[_CIE_DIAGRAM_TYPE],
                                          vPosAsInt2.x,
                                          fetchPos.y);

    Out.rgb += fetchedPixel;
  }
#ifdef IS_HDR_CSP
  if (SHOW_CIE_CSP_DCI_P3_OUTLINE)
  {
    float3 fetchedPixel = FetchCspOutline(int(CIE_TEXTURE_ENTRY_DCI_P3_OUTLINE),
                                          CIE_BG_WIDTH_AS_INT[_CIE_DIAGRAM_TYPE],
                                          vPosAsInt2.x,
                                          fetchPos.y);

    Out.rgb += fetchedPixel;
  }
  if (SHOW_CIE_CSP_BT2020_OUTLINE)
  {
    float3 fetchedPixel = FetchCspOutline(int(CIE_TEXTURE_ENTRY_BT2020_OUTLINE),
                                          CIE_BG_WIDTH_AS_INT[_CIE_DIAGRAM_TYPE],
                                          vPosAsInt2.x,
                                          fetchPos.y);

    Out.rgb += fetchedPixel;
  }
#ifdef IS_FLOAT_HDR_CSP
  if (SHOW_CIE_CSP_AP0_OUTLINE)
  {
    float3 fetchedPixel = FetchCspOutline(int(CIE_TEXTURE_ENTRY_AP0_OUTLINE),
                                          CIE_BG_WIDTH_AS_INT[_CIE_DIAGRAM_TYPE],
                                          vPosAsInt2.x,
                                          fetchPos.y);

    Out.rgb += fetchedPixel;
  }
#endif
#endif

  // using gamma 2 as intermediate gamma space
  Out.rgb = sqrt(Out.rgb);

  return;
}

void CS_GenerateCieDiagram(uint3 ID : SV_DispatchThreadID)
{
  if (_SHOW_CIE)
  {

#if !defined(WIDTH1_DISPATCH_DOESNT_OVERFLOW)  \
 && !defined(HEIGHT1_DISPATCH_DOESNT_OVERFLOW)

    if (ID.x < BUFFER_WIDTH && ID.y < BUFFER_HEIGHT)
    {

#elif !defined(WIDTH1_DISPATCH_DOESNT_OVERFLOW)  \
    && defined(HEIGHT1_DISPATCH_DOESNT_OVERFLOW)

    if (ID.y < BUFFER_HEIGHT)
    {

#elif !defined(HEIGHT1_DISPATCH_DOESNT_OVERFLOW) \
    && defined(WIDTH1_DISPATCH_DOESNT_OVERFLOW)

    if (ID.y < BUFFER_WIDTH)
    {

#endif

      precise const float3 pixel = tex2Dfetch(ReShade::BackBuffer, ID.xy).rgb;

      if (all(pixel == 0.f))
      {
        return;
      }

    // get XYZ
#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB)

      precise const float3 XYZ = Csp::Mat::Bt709To::XYZ(pixel);

#elif (ACTUAL_COLOUR_SPACE == CSP_HDR10)

      precise const float3 XYZ = Csp::Mat::Bt2020To::XYZ(Csp::Trc::PqTo::Linear(pixel));

#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)

      precise const float3 XYZ = Csp::Mat::Bt2020To::XYZ(Csp::Trc::HlgTo::Linear(pixel));

#elif (ACTUAL_COLOUR_SPACE == CSP_PS5)

      precise const float3 XYZ = Csp::Mat::Bt2020To::XYZ(pixel);

#elif (ACTUAL_COLOUR_SPACE == CSP_SRGB)

      precise const float3 XYZ  = Csp::Mat::Bt709To::XYZ(DECODE_SDR(pixel));

#else

      precise const float3 XYZ = float3(0.f, 0.f, 0.f);

#endif

//ignore negative luminance in float based colour spaces
#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB \
  || ACTUAL_COLOUR_SPACE == CSP_PS5)

      if (XYZ.y <= 0.f)
      {
        return;
      }

#endif

      if (_CIE_DIAGRAM_TYPE == CIE_1931)
      {
        // get xy
        precise const float xyz = XYZ.x + XYZ.y + XYZ.z;

        precise int2 xy = int2(round(XYZ.x / xyz * float(CIE_ORIGINAL_DIM)),
         CIE_1931_HEIGHT - 1 - round(XYZ.y / xyz * float(CIE_ORIGINAL_DIM)));

        // adjust for the added borders
        xy += CIE_BG_BORDER;

        // clamp to borders
        xy = clamp(xy, CIE_BG_BORDER, CIE_1931_SIZE + CIE_BG_BORDER);

        // leave this as sampler and not storage
        // otherwise d3d complains about the resource still being bound on input
        // D3D11 WARNING: ID3D11DeviceContext::CSSetUnorderedAccessViews:
        // Resource being set to CS UnorderedAccessView slot 3 is still bound on input!
        // [ STATE_SETTING WARNING #2097354: DEVICE_CSSETUNORDEREDACCESSVIEWS_HAZARD]
        const float4 xyColour = tex2Dfetch(SamplerCieConsolidated, xy);

        tex2Dstore(StorageCieCurrent,
                   xy,
                   xyColour);
      }
      else if (_CIE_DIAGRAM_TYPE == CIE_1976)
      {
        // get u'v'
        precise const float X15Y3Z = XYZ.x
                                   + 15.f * XYZ.y
                                   +  3.f * XYZ.z;

        precise int2 uv = int2(round(4.f * XYZ.x / X15Y3Z * float(CIE_ORIGINAL_DIM)),
         CIE_1976_HEIGHT - 1 - round(9.f * XYZ.y / X15Y3Z * float(CIE_ORIGINAL_DIM)));

        // adjust for the added borders
        uv += CIE_BG_BORDER;

        // clamp to borders
        uv = clamp(uv, CIE_BG_BORDER, CIE_1976_SIZE + CIE_BG_BORDER);

        const int2 uvFetchPos = int2(uv.x, uv.y + CIE_1931_BG_HEIGHT);

        // leave this as sampler and not storage
        // otherwise d3d complains about the resource still being bound on input
        // D3D11 WARNING: ID3D11DeviceContext::CSSetUnorderedAccessViews:
        // Resource being set to CS UnorderedAccessView slot 3 is still bound on input!
        // [ STATE_SETTING WARNING #2097354: DEVICE_CSSETUNORDEREDACCESSVIEWS_HAZARD]
        const float4 uvColour = tex2Dfetch(SamplerCieConsolidated, uvFetchPos);

        tex2Dstore(StorageCieCurrent,
                   uv,
                   uvColour);
      }

#if (!defined(WIDTH1_DISPATCH_DOESNT_OVERFLOW)  && !defined(HEIGHT1_DISPATCH_DOESNT_OVERFLOW)) \
 || (!defined(WIDTH1_DISPATCH_DOESNT_OVERFLOW)  &&  defined(HEIGHT1_DISPATCH_DOESNT_OVERFLOW)) \
 || ( defined(WIDTH1_DISPATCH_DOESNT_OVERFLOW)  && !defined(HEIGHT1_DISPATCH_DOESNT_OVERFLOW))

    }

#endif
  }
}

#ifdef IS_HDR_CSP
bool IsCsp(precise float3 Rgb)
{
  if (all(Rgb >= 0.f))
  {
    return true;
  }
  return false;
}

#define IS_CSP_BT709   0
#define IS_CSP_DCI_P3  1
#define IS_CSP_BT2020  2
#define IS_CSP_AP0     3
#define IS_CSP_INVALID 4

#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB)

  #define _IS_CSP_BT709(Rgb)  Rgb
  #define _IS_CSP_DCI_P3(Rgb) Csp::Mat::Bt709To::DciP3(Rgb)
  #define _IS_CSP_BT2020(Rgb) Csp::Mat::Bt709To::Bt2020(Rgb)
  #define _IS_CSP_AP0(Rgb)    Csp::Mat::Bt709To::Ap0D65(Rgb)

#elif (defined(IS_HDR10_LIKE_CSP) \
    || ACTUAL_COLOUR_SPACE == CSP_PS5)

  #define _IS_CSP_BT709(Rgb)  Csp::Mat::Bt2020To::Bt709(Rgb)
  #define _IS_CSP_DCI_P3(Rgb) Csp::Mat::Bt2020To::DciP3(Rgb)
  #define _IS_CSP_BT2020(Rgb) Rgb
  #define _IS_CSP_AP0(Rgb)    Csp::Mat::Bt2020To::Ap0D65(Rgb)

#endif

float GetCsp(precise float3 Rgb)
{
  if (IsCsp(_IS_CSP_BT709(Rgb)))
  {
    return IS_CSP_BT709;
  }
  else if (IsCsp(_IS_CSP_DCI_P3(Rgb)))
  {
    return IS_CSP_DCI_P3 / 255.f;
  }

#if defined(IS_HDR10_LIKE_CSP)

  else
  {
    return IS_CSP_BT2020 / 255.f;
  }

#else

  else if (IsCsp(_IS_CSP_BT2020(Rgb)))
  {
    return IS_CSP_BT2020 / 255.f;
  }
  else if (IsCsp(_IS_CSP_AP0(Rgb)))
  {
    return IS_CSP_AP0 / 255.f;
  }
  else
  {
    return IS_CSP_INVALID / 255.f;
  }

#endif //IS_HDR10_LIKE_CSP

  return IS_CSP_INVALID / 255.f;
}

void PS_CalcCsps(
              float4 VPos     : SV_Position,
              float2 TexCoord : TEXCOORD0,
  out precise float  CurCsp   : SV_Target0)
{
  CurCsp = 0.f;

  if (SHOW_CSPS
   || SHOW_CSP_FROM_CURSOR
   || SHOW_CSP_MAP)
  {
    precise const float3 pixel = tex2Dfetch(ReShade::BackBuffer, int2(VPos.xy)).rgb;

#if defined(IS_FLOAT_HDR_CSP)

#if (IGNORE_NEAR_BLACK_VALUES_FOR_CSP_DETECTION == YES)

    const float3 absPixel = abs(pixel);
    if (absPixel.r > SMALLEST_FP16
     && absPixel.g > SMALLEST_FP16
     && absPixel.b > SMALLEST_FP16)
    {
      CurCsp = GetCsp(pixel);
    }
    else
    {
      CurCsp = IS_CSP_BT709;
    }
    return;

#else

    CurCsp = GetCsp(pixel);

    return;

#endif

#elif defined(IS_HDR10_LIKE_CSP)

#if (IGNORE_NEAR_BLACK_VALUES_FOR_CSP_DETECTION == YES)

    if (pixel.r > SMALLEST_UINT10
     && pixel.g > SMALLEST_UINT10
     && pixel.b > SMALLEST_UINT10)
    {
#if (ACTUAL_COLOUR_SPACE == CSP_HDR10)
      precise const float3 curPixel = Csp::Trc::PqTo::Linear(pixel);
#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)
      precise const float3 curPixel = Csp::Trc::HlgTo::Linear(pixel);
#endif
      CurCsp = GetCsp(curPixel);
    }
    else
    {
      CurCsp = IS_CSP_BT709;
    }
    return;

#else

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10)
    precise const float3 curPixel = Csp::Trc::PqTo::Linear(pixel);
#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)
    precise const float3 curPixel = Csp::Trc::HlgTo::Linear(pixel);
#endif
    CurCsp = GetCsp(curPixel);

    return;

#endif

#else

    CurCsp = IS_CSP_INVALID / 255.f;

    return;

#endif
  }
  discard;
}


#define COORDS_CSP_COUNTER_BT709(X) \
  int2(X + CSP_COUNTER_X_OFFSET, IS_CSP_BT709   + CSP_COUNTER_Y_OFFSET)
#define COORDS_CSP_COUNTER_DCI_P3(X) \
  int2(X + CSP_COUNTER_X_OFFSET, IS_CSP_DCI_P3  + CSP_COUNTER_Y_OFFSET)
#define COORDS_CSP_COUNTER_BT2020(X) \
  int2(X + CSP_COUNTER_X_OFFSET, IS_CSP_BT2020  + CSP_COUNTER_Y_OFFSET)
#define COORDS_CSP_COUNTER_AP0(X) \
  int2(X + CSP_COUNTER_X_OFFSET, IS_CSP_AP0     + CSP_COUNTER_Y_OFFSET)
#define COORDS_CSP_COUNTER_INVALID(X) \
  int2(X + CSP_COUNTER_X_OFFSET, IS_CSP_INVALID + CSP_COUNTER_Y_OFFSET)


void CS_CountCspsY(uint3 ID : SV_DispatchThreadID)
{
  if (SHOW_CSPS
   || SHOW_CSP_FROM_CURSOR
   || SHOW_CSP_MAP)
  {
#ifndef WIDTH0_DISPATCH_DOESNT_OVERFLOW

    if (ID.x < BUFFER_WIDTH)
    {

#endif

      precise uint counter_BT709  = 0;
      precise uint counter_DCI_P3 = 0;

#if defined(IS_FLOAT_HDR_CSP)

      precise uint counter_BT2020 = 0;
      precise uint counter_AP0    = 0;

#endif //IS_FLOAT_HDR_CSP

      for (int y = 0; y < BUFFER_HEIGHT; y++)
      {
        uint curCsp = uint(tex2Dfetch(SamplerCsps, int2(ID.x, y)) * 255.f);
        if (curCsp == IS_CSP_BT709)
        {
          counter_BT709++;
        }
        else if (curCsp == IS_CSP_DCI_P3)
        {
          counter_DCI_P3++;
        }

#if defined(IS_FLOAT_HDR_CSP)

        else if (curCsp == IS_CSP_BT2020)
        {
          counter_BT2020++;
        }
        else if (curCsp == IS_CSP_AP0)
        {
          counter_AP0++;
        }

#endif //IS_FLOAT_HDR_CSP
      }

      tex2Dstore(StorageConsolidated, COORDS_CSP_COUNTER_BT709(ID.x),  counter_BT709);
      tex2Dstore(StorageConsolidated, COORDS_CSP_COUNTER_DCI_P3(ID.x), counter_DCI_P3);

#if defined(IS_FLOAT_HDR_CSP)

      tex2Dstore(StorageConsolidated, COORDS_CSP_COUNTER_BT2020(ID.x), counter_BT2020);
      tex2Dstore(StorageConsolidated, COORDS_CSP_COUNTER_AP0(ID.x),    counter_AP0);

#endif //IS_FLOAT_HDR_CSP

#ifndef WIDTH0_DISPATCH_DOESNT_OVERFLOW

    }

#endif
  }
}

void CS_CountCspsX(uint3 ID : SV_DispatchThreadID)
{
  if (SHOW_CSPS
   || SHOW_CSP_FROM_CURSOR
   || SHOW_CSP_MAP)
  {
    precise uint counter_BT709  = 0;
    precise uint counter_DCI_P3 = 0;

#if defined(IS_FLOAT_HDR_CSP)

    precise uint counter_BT2020 = 0;
    precise uint counter_AP0    = 0;

#endif //IS_FLOAT_HDR_CSP

    for (int x = 0; x < BUFFER_WIDTH; x++)
    {
      counter_BT709  += uint(tex2Dfetch(StorageConsolidated, COORDS_CSP_COUNTER_BT709(x)));
      counter_DCI_P3 += uint(tex2Dfetch(StorageConsolidated, COORDS_CSP_COUNTER_DCI_P3(x)));

#if defined(IS_FLOAT_HDR_CSP)

      counter_BT2020 += uint(tex2Dfetch(StorageConsolidated, COORDS_CSP_COUNTER_BT2020(x)));
      counter_AP0    += uint(tex2Dfetch(StorageConsolidated, COORDS_CSP_COUNTER_AP0(x)));

#endif //IS_FLOAT_HDR_CSP
    }

    barrier();

    precise float percentageBt709 = counter_BT709  / PIXELS;
    precise float percentageDciP3 = counter_DCI_P3 / PIXELS;
    tex2Dstore(StorageConsolidated, COORDS_CSP_PERCENTAGE_BT709,  percentageBt709);
    tex2Dstore(StorageConsolidated, COORDS_CSP_PERCENTAGE_DCI_P3, percentageDciP3);

#if defined(IS_FLOAT_HDR_CSP)

    precise float percentageBt2020 = counter_BT2020 / PIXELS;
    precise float percentageAp0    = counter_AP0    / PIXELS;
    tex2Dstore(StorageConsolidated, COORDS_CSP_PERCENTAGE_BT2020, percentageBt2020);
    tex2Dstore(StorageConsolidated, COORDS_CSP_PERCENTAGE_AP0,    percentageAp0);

#endif //IS_FLOAT_HDR_CSP
  }
}

float3 CreateCspMap(
  uint  Csp,
  float Y)
//  float WhitePoint)
{
  if (SHOW_CSP_MAP)
  {
    float3 output;

    if (Csp != IS_CSP_BT709)
    {
      Y += 20.f;
    }

    switch(Csp)
    {
      case IS_CSP_BT709:
      {
        // shades of grey
        float clamped = Y * 0.25f;
        output = float3(clamped,
                        clamped,
                        clamped);
      } break;
      case IS_CSP_DCI_P3:
      {
        // yellow
        output = float3(Y,
                        Y,
                        0.f);
      } break;
      case IS_CSP_BT2020:
      {
        // blue
        output = float3(0.f,
                        0.f,
                        Y);
      } break;
      case IS_CSP_AP0:
      {
        // red
        output = float3(Y,
                        0.f,
                        0.f);
      } break;
      default: // invalid
      {
        // pink
        output = float3(Y,
                        0.f,
                        Y);
      } break;
    }

#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB)

    output /= 80.f;

#elif (ACTUAL_COLOUR_SPACE == CSP_HDR10)

    output = Csp::Trc::NitsTo::Pq(Csp::Mat::Bt709To::Bt2020(output));

#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)

    output = Csp::Trc::NitsTo::Hlg(Csp::Mat::Bt709To::Bt2020(output));

#elif (ACTUAL_COLOUR_SPACE == CSP_PS5)

    output = Csp::Mat::Bt709To::Bt2020(output / 100.f);

#endif

    return output;
  }
}
#endif //IS_HDR_CSP

void ShowValuesCopy(uint3 ID : SV_DispatchThreadID)
{
  float frametimeCounter = tex2Dfetch(StorageConsolidated, COORDS_UPDATE_OVERLAY_PERCENTAGES);
  frametimeCounter += FRAMETIME;

  // only update every 1/2 of a second
  if (frametimeCounter >= 500.f)
  {
    tex2Dstore(StorageConsolidated, COORDS_UPDATE_OVERLAY_PERCENTAGES, 0.f);

    float maxNits = tex2Dfetch(StorageConsolidated, COORDS_MAX_NITS_VALUE);
    float avgNits = tex2Dfetch(StorageConsolidated, COORDS_AVG_NITS_VALUE);
    float minNits = tex2Dfetch(StorageConsolidated, COORDS_MIN_NITS_VALUE);

    // avoid average being higher than max in extreme edge cases
    avgNits = min(avgNits, maxNits);

#ifdef IS_HDR_CSP
    precise float counter_BT709  = tex2Dfetch(StorageConsolidated, COORDS_CSP_PERCENTAGE_BT709)
#if (__VENDOR__ == 0x1002)
                                 * 100.0001f;
#else
                                 * 100.f;
#endif
    precise float counter_DCI_P3 = tex2Dfetch(StorageConsolidated, COORDS_CSP_PERCENTAGE_DCI_P3)
#if (__VENDOR__ == 0x1002)
                                 * 100.0001f;
#else
                                 * 100.f;
#endif

#if defined(IS_FLOAT_HDR_CSP)

    precise float counter_BT2020 = tex2Dfetch(StorageConsolidated, COORDS_CSP_PERCENTAGE_BT2020)
#if (__VENDOR__ == 0x1002)
                                 * 100.0001f;
#else
                                 * 100.f;
#endif

#else

    precise float counter_BT2020 = 100.f
                                 - counter_DCI_P3
                                 - counter_BT709;

#endif //IS_FLOAT_HDR_CSP

#if defined(IS_FLOAT_HDR_CSP)

    precise float counter_AP0     = tex2Dfetch(StorageConsolidated, COORDS_CSP_PERCENTAGE_AP0)
#if (__VENDOR__ == 0x1002)
                                 * 100.0001f;
#else
                                 * 100.f;
#endif
    precise float counter_invalid = 100.f
                                  - counter_AP0
                                  - counter_BT2020
                                  - counter_DCI_P3
                                  - counter_BT709;

#endif //IS_FLOAT_HDR_CSP
#endif //IS_HDR_CSP

    barrier();

    tex2Dstore(StorageConsolidated, COORDS_SHOW_MAX_NITS, maxNits);
    tex2Dstore(StorageConsolidated, COORDS_SHOW_AVG_NITS, avgNits);
    tex2Dstore(StorageConsolidated, COORDS_SHOW_MIN_NITS, minNits);

#ifdef IS_HDR_CSP

    tex2Dstore(StorageConsolidated, COORDS_SHOW_PERCENTAGE_BT709,  counter_BT709);
    tex2Dstore(StorageConsolidated, COORDS_SHOW_PERCENTAGE_DCI_P3, counter_DCI_P3);
    tex2Dstore(StorageConsolidated, COORDS_SHOW_PERCENTAGE_BT2020, counter_BT2020);

#if defined(IS_FLOAT_HDR_CSP)

    tex2Dstore(StorageConsolidated, COORDS_SHOW_PERCENTAGE_AP0,     counter_AP0);
    tex2Dstore(StorageConsolidated, COORDS_SHOW_PERCENTAGE_INVALID, counter_invalid);

#endif //IS_FLOAT_HDR_CSP
#endif //IS_HDR_CSP

  }
  else
  {
    tex2Dstore(StorageConsolidated, COORDS_UPDATE_OVERLAY_PERCENTAGES, frametimeCounter);
  }
  return;
}

#endif //ANALYSIS_ENABLE

#endif //is hdr API and hdr colour space
