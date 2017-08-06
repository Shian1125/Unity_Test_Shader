// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Sample"
{
	Properties
	{
		_Texture("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{"Queue" = "Geometry" "RenderType" = "Opaque"}
		LOD 100

		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert					//定義一個vertex shader, 她使用的方法為vert
			#pragma fragment frag
			
			sampler2D _Texture;					//將外面定義好的參數拿進CG語法中使用(名稱需相同)
			fixed4 _Color;

			//(input)要跟unity取得頂點資訊，使用struct的方式進行資料交換
			struct appdata
			{			
				fixed4 vertex : POSITION;		//模型頂點位置，冒號後為語意，即告訴unity vertex這個參數的含意，unity就會將頂點資訊傳入vertex
				fixed2 uv : TEXCOORD0;			//UV位置
			};

			//(output)vertex shader的資料結構傳給unity後，unity再傳至fragment shader，這會需要另一個資料結構
			struct v2f
			{
				fixed4 vertex : SV_POSITION;	//SV = SystemValue，此語意為讓unity作一些特殊處理，像光柵化
				fixed2 uv : TEXCOORD0;

			};

			//回傳一個v2f給unity，unity再將此v2f傳給fragment shader
			v2f vert(appdata i)					//在vertex shader中，需要做的事情為vertex transform
			{
				v2f o;
				o.uv = i.uv;
				//矩陣相乘進行座標系的轉換。MVP為vertex shader中modeling, viewing, projection三種transform，即為將頂點資訊從local position轉換到clip space(裁剪空間)，unity再呼叫硬體，將頂點轉換至NDC中
				o.vertex = UnityObjectToClipPos(i.vertex);
				return o;
			}

			//fragment shader 輸出的是一個顏色值(fixed4)
			fixed4 frag(v2f v) : SV_Target		//SV_TARGET為fixed4這個顏色值的語意，她是一個render target(渲染目標)，她會把這個渲染的目標顯示在畫面上
			{
				//把texture根據輸入的UV位置映射，之後再與我們的顏色進行混合
				return tex2D(_Texture, v.uv) * _Color;
			}
			ENDCG
		}
	}
}