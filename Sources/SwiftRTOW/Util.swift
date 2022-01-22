typealias C = float3

func clamp(x: Float, min: Float, max: Float) -> Float {
	return min>x ? min : x>max ? max : x
}
