Shader "Cookbook Shaders/Chapter 12/FurShader"
{
    Properties
    {
        // Base texture for the fur
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _Color ("Fur Color", Color) = (1, 1, 1, 1)

        // Length of the fur strands
        _FurLength ("Fur Length", Range(0.01, 1.0)) = 0.1
        
        // Minimum alpha value for visibility
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5   
        
        // Maximum alpha value for fur fade
        _CutoffEnd ("Alpha Cutoff End", Range(0, 1)) = 0.5

        // Edge fade factor for the fur
        _EdgeFade ("Edge Fade", Range(0, 1)) = 0.5

        // Direction of gravity
        _Gravity ("Gravity Direction", Vector) = (0, -1, 0, 0)

        // Strength of gravity effect
        _GravityStr ("Gravity Strength", Range(0, 1)) = 0.25  
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" }
        LOD 100

        Pass
        {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 color : COLOR; // Adding vertex color for alpha
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _FurLength;
            float _Cutoff;
            float _CutoffEnd;
            float _EdgeFade;
            float4 _Gravity;
            float _GravityStr;
            float _FUR_MULTIPLIER;             // Multiplier for fur layering

            float3 CalculateFurOffset(float3 normalWS, float3 gravityDir, float alpha)
            {
                float3 direction = lerp(
                    normalWS,
                    normalize(gravityDir * _GravityStr + normalWS * (1.0 - _GravityStr)),
                    _FUR_MULTIPLIER
                );
                return direction * _FurLength * _FUR_MULTIPLIER * alpha;
            }

            v2f vert(appdata v)
            {
                v2f o;

                // Transform normal and position to world space
                float3 normalWS = TransformObjectToWorldNormal(v.normal);
                float3 worldPos = TransformObjectToWorld(v.vertex.xyz);

                // Calculate view direction in world space
                float3 viewDirWS = normalize(TransformWorldToViewDir(worldPos));

                // Normalize gravity direction
                float3 gravityDir = normalize(_Gravity.xyz);

                // Compute fur offset
                float3 furOffset = CalculateFurOffset(normalWS, gravityDir, v.color.a);
                worldPos += furOffset;

                // Pass data to fragment shader
                o.vertex = TransformWorldToHClip(worldPos);
                o.worldPos = worldPos;
                o.worldNormal = normalWS;
                o.viewDir = viewDirWS;
                o.uv = v.uv;

                return o;
            }

            float CalculateAlphaFade(float alpha, float3 viewDir, float3 normalWS)
            {
                float edgeFade = 1.0 - (_FUR_MULTIPLIER * _FUR_MULTIPLIER);
                edgeFade += dot(normalize(viewDir), normalize(normalWS)) - _EdgeFade;
                return saturate(alpha * edgeFade);
            }

            float4 frag(v2f i) : SV_Target
            {
                // Sample the base texture
                float4 texColor = tex2D(_MainTex, i.uv);

                // Apply alpha fade
                float alpha = step(lerp(_Cutoff,_CutoffEnd,_FUR_MULTIPLIER), texColor.a);

                alpha *= CalculateAlphaFade(alpha, i.viewDir, normalize(i.worldNormal));

                // Discard fragments below cutoff
                if (alpha < _Cutoff)
                    discard;

                // Apply color tint
                texColor.rgb *= _Color.rgb;

                return texColor;
            }
            ENDHLSL
        }
    }
}
