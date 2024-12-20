#ifndef MY_HLSL_INCLUDE
#define MY_HLSL_INCLUDE

float4 _MyColor;

/*
 * Function name: LightingHalfLambert
 * Function description: Computes diffuse lighting using the Half-Lambert model, 
 *                       modulates the result with base color, light color, 
 *                       and a user-defined color (_MyColor).
 *
 * Parameters:
 *       normal (float3):       The normalized surface normal.
 *       lightDir (float3):     The normalized direction to the light source.
 *       lightColor (float3):   The color of the light source.
 *       baseColor (float3):    The base color of the material or texture.
 *       atten (float):         The light attenuation factor.
 *
 * Returns:
 *       float3: The final lit color after applying Half-Lambert shading and 
 *               color modulation.
 */
inline float3 LightingHalfLambert(float3 normal, 
                                  float3 lightDir, 
                                  float3 lightColor, 
                                  float3 baseColor, 
                                  float atten)
{
    // Calculate Half-Lambert diffuse factor
    float diff = max(0, dot(normal, lightDir));
    diff = (diff + 0.5) * 0.5;

    // Calculate final color
    float3 resultColor;
    
    resultColor = baseColor * lightColor * diff * 
                      atten * _MyColor.rgb;
    
    return resultColor; 
}

#endif