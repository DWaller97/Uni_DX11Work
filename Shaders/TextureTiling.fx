//--------------------------------------------------------------------------------------
// File: DX11 Framework.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------

Texture2D txDiffuse : register(t0);
SamplerState samLinear : register(s0);


cbuffer ConstantBuffer : register(b0)
{
	matrix World;

	matrix View;

	matrix Projection;

	float pad;
	float3 LightVecW;

	float4 DiffuseMtrl;
	float4 DiffuseLight;
	float3 AmbientMtrl;
	float a = 0;

	float3 AmbientLight;
	float specularPower;

	float4 cameraEye;
	float3 specularMtrl;
	float padding;
	float3 specularLight;
	float morePadding;
}


//--------------------------------------------------------------------------------------
struct VS_INPUT
{
	float4 Pos : POSITION;
	float3 Normal : NORMAL;
	float2 Tex : TEXCOORD0;

};

struct PS_INPUT
{
	float4 Pos : SV_POSITION;
	float3 Normal : NORMAL;
	float2 Tex : TEXCOORD0;
    float3 ToEye : TEXCOORD1;
};

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS(VS_INPUT input)
{
    PS_INPUT output = (PS_INPUT) 0;
    output.Pos = mul(input.Pos, World);
    output.Pos = mul(output.Pos, View);
    output.Pos = mul(output.Pos, Projection);
    // Convert from local space to world space 
    // W component of vector is 0 as vectors cannot be translated
    float3 normalW = mul(float4(input.Normal, 0.0f), World).xyz;
    normalW = normalize(normalW);
    
    float3 vertexPos = mul(input.Pos, World);

    output.ToEye = normalize(cameraEye.xyz - vertexPos.xyz);
    output.Normal = normalW;
	
    float2 tex = input.Tex;


        tex.x *= 300;

        tex.y *= 300;


    output.Tex = tex;
	return output;

    }



//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT input) : SV_Target
{
    float3 normal = normalize(input.Normal);
    float3 r = reflect(-LightVecW, normal);
    
    float amount = max(dot(normal, LightVecW), 0.0f);

    float3 diffuse = amount * (DiffuseLight * DiffuseMtrl).rgb;
    float3 ambient = (AmbientMtrl * AmbientLight).rgb;
    float3 specular = pow(max(dot(input.ToEye, r), 0), specularPower) * (specularLight * specularMtrl);
    float4 colour;
    colour.rgb = diffuse + ambient + specular;
    colour.a = DiffuseMtrl.a;
    float4 textureColour = colour + txDiffuse.Sample(samLinear, input.Tex);
    clip(textureColour.a - 0.95f);
    return textureColour;
}