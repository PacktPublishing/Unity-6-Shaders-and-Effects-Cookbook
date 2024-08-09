/* If CUSTOM_LIGHTING_INCLUDED is not defined, define it */
#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED 

/* Main function to calculate Shadow Attenuation for a given world position */
void GetShadowAtten_float(float3 WorldPos,
                     out float ShadowAtten)
{
#if SHADERGRAPH_PREVIEW
    /* Set shadow attenuation for preview mode */
    ShadowAtten = 1.0;
#else
    // Transform the world position to shadow coordinates 
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);

#if !defined(_MAIN_LIGHT_SHADOWS) || defined(_RECEIVE_SHADOWS_OFF)
    /* No shadow attenuation if shadows are disabled */
    ShadowAtten = 1.0h;
#else
    /* Get shadow sampling data for the main light */
    ShadowSamplingData shadowSamplingData = 
        GetMainLightShadowSamplingData();

    /* Get shadow strength for the main light */
    float shadowStrength = GetMainLightShadowStrength();

    // Sample the shadow map to get the shadow attenuation 
    ShadowAtten = SampleShadowmap(shadowCoord, 
            TEXTURE2D_ARGS(_MainLightShadowmapTexture,     
                        sampler_MainLightShadowmapTexture), 
                            shadowSamplingData, 
                            shadowStrength, 
                            false
    );
#endif  /* End of shadow check */
#endif  /* End of SHADERGRAPH_PREVIEW check */
}

/* Function to calculate additional light contributions */
void AdditionalLights_float( float3 WorldPosition,
                             float3 WorldNormal,
                             float3 WorldView,
                             float3 SpecColor,
                             float Smoothness,
                             float SpecPower,
                             out float3 Diffuse,
                             out float3 Specular)
{
    /* Diffuse and specular color accumulators */
    float3 diffuseColor = 0;
    float3 specularColor = 0;

#ifndef SHADERGRAPH_PREVIEW
    /* Adjust Smoothness for better visual results */
    Smoothness = exp2(10 * Smoothness + 1);

    /* Get count of lights affecting the pixel */
    uint pixelLightCount = GetAdditionalLightsCount();

    /* Prepare inputData for Forward+ */
    InputData inputData = (InputData) 0;
    float4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
    inputData.normalizedScreenSpaceUV = screenPos.xy / 
                                        screenPos.w;
    inputData.positionWS = WorldPosition;

    /* Begin light loop for additional lights */
    LIGHT_LOOP_BEGIN(pixelLightCount)

    /* Get the properties of the current light */
    Light light = GetAdditionalLight(lightIndex,
                                         WorldPosition);

    /* Blinn-Phong shading model */
    float3 attenuatedLightColor =
            light.color *
            (light.distanceAttenuation *
                light.shadowAttenuation);
            
    /* Accumulate diffuse lighting contribution */
    diffuseColor += LightingLambert(attenuatedLightColor,
                                        light.direction,
                                        WorldNormal);
            
    /* Accumulate specular lighting contribution */
    specularColor += LightingSpecular(attenuatedLightColor,
                                            light.direction,
                                            WorldNormal,
                                            WorldView,
                                     float4(SpecColor, 
                                            SpecPower),
                                            Smoothness);
    LIGHT_LOOP_END
    
#endif /* End of SHADERGRAPH_PREVIEW check */

    /* Output the accumulated colors */
    Diffuse = diffuseColor;
    Specular = specularColor;
}


#endif  /* End of CUSTOM_LIGHTING_INCLUDED check */
