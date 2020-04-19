Shader "Effects/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normalmap", 2D) = "bump" {}
        _ScaleUV ("Scale", Range(1,20)) = 1
    }
    SubShader
    {
        // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Transparent" }

        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_BackgroundTexture"
        }

        // Render the object with the texture generated above, and invert the colors
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
                float4 grabPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float2 uvbump : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            sampler2D _BackgroundTexture;
            float4 _BackgroundTexture_TexelSize;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _ScaleUV;

            v2f vert(appdata v) {
                v2f o;
                // use UnityObjectToClipPos from UnityCG.cginc to calculate 
                // the clip-space of the vertex
                o.pos = UnityObjectToClipPos(v.vertex);
                // use ComputeGrabScreenPos function from UnityCG.cginc
                // to get the correct texture coordinate
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.uv = TRANSFORM_TEX( v.uv, _MainTex);
                o.uvbump = TRANSFORM_TEX( v.uv, _BumpMap );
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half2 bump = UnpackNormal(tex2D( _BumpMap, i.uvbump )).rg; 
                float2 offset = bump * _ScaleUV * _BackgroundTexture_TexelSize.xy;
                i.grabPos.xy = offset * i.grabPos.z + i.grabPos.xy;

                half4 bgcolor = tex2Dproj(_BackgroundTexture, i.grabPos);
                fixed4 tint = tex2D(_MainTex, i.uv);
                return bgcolor * tint;
            }
            ENDCG
        }

    }
}