Shader "Custom/CubeMapEmission" 
{
    Properties {
        _CubeMap ("Cube Map", CUBE) = "white" {}
    }
    SubShader {

      CGPROGRAM
        #pragma surface surf Lambert
        
        samplerCUBE _CubeMap;

        struct Input {
            float3 worldRefl; INTERNAL_DATA
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
        
            o.Emission = texCUBE (_CubeMap, WorldReflectionVector (IN, o.Normal)).rgb;
        }
      
      ENDCG
    }
    Fallback "Diffuse"
  }