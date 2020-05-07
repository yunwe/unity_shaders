Shader "Unlit/SafeZone"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Zone("Zone", Range(1, 0)) = 0.3
        _Outline("Outline Width", Range(1, 3)) = 1
        _Intensity("Intensity", Range(0.3, 0.8)) = 0.5
        _RimArea("Rim Area", Range(1, 3)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        Lighting Off ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };
            
            float4 _Color;
            half _Zone;
            half _Outline;
            half _Intensity;
            half _RimArea;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            bool InRadius(half dist, half radius)
            {
                return dist < radius;
            }
            

            fixed4 frag (v2f i) : SV_Target
            {
            

                // sample the texture
                fixed4 col = _Color;
                half radius = _Zone / 2;
                float2 center = float2(0.5,0.5);
                half dist = distance(i.uv, center);
                
                bool isInRadius = InRadius(dist, radius);
                col.a = isInRadius? 0 : _Intensity - ((dist - radius) * (4 - _RimArea));

                if(InRadius(dist , radius + _Outline * 0.01) && !isInRadius)
                {
                    col.a = 1;
                }

                //col.a = InRadius(i.uv, float2(0.5,0.5), radius)? 0 : 0.5;
                return col;
            }
            ENDCG
        }
    }
}
