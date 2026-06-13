using UnityEngine;

public static class HeightCalculator
{
    // ARKit (via AR Foundation) uses Y-up world space, gravity-aligned by IMU
    public static float VerticalHeight(Vector3 bottom, Vector3 top) => Mathf.Abs(top.y - bottom.y);
    public static float EuclideanDistance(Vector3 a, Vector3 b) => Vector3.Distance(a, b);
}
