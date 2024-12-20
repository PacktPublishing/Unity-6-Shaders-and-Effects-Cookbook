Shader "CookbookShaders/URP/Heatmap"
{
    Properties
    {
        _HeatTex("Gradient Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent"}
        LOD 100

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            // Heatmap data
            uniform int _Points_Length = 0;
            uniform float3 _Points[20];      // Position of points
            uniform float2 _Properties[20]; // Radius and intensity

            sampler2D _HeatTex; // Gradient texture

            // Vertex shader
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }

            // Fragment shader
            half4 frag(v2f i) : SV_Target
            {
                half h = 0.0;

                // Calculate heatmap contribution
                for (int j = 0; j < _Points_Length; j++)
                {
                    half di = distance(i.worldPos, _Points[j].xyz);
                    half ri = _Properties[j].x; // Radius
                    half hi = 1.0 - saturate(di / ri); // Heat intensity
                    h += hi * _Properties[j].y;       // Add weighted intensity
                }

                h = saturate(h); // Clamp heat value to 0-1
                half4 color = tex2D(_HeatTex, float2(h, 0.5)); // Map to gradient
                return color;
            }

            ENDHLSL
        }
    }
}
