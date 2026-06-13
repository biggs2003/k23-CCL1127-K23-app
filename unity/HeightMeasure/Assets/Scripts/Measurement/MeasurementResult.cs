using UnityEngine;
using System;

[Serializable]
public class MeasurementResult
{
    public float verticalHeight;
    public float euclideanDistance;
    public HeightCategory category;
    public Vector3 bottomPoint;
    public Vector3 topPoint;
    public DateTime timestamp;

    public bool ShowsSlantDistance => Mathf.Abs(euclideanDistance - verticalHeight) > 0.02f;
}
