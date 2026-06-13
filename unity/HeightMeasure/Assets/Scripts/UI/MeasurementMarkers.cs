using UnityEngine;

/// Manages the 3D world-space sphere markers and measurement line in AR space.
/// Markers and the line are created/destroyed programmatically — no prefabs needed.
public class MeasurementMarkers : MonoBehaviour
{
    [SerializeField] MeasurementSession session;

    [Tooltip("Width of the measurement line in metres (default 5 mm).")]
    [SerializeField] float lineWidth = 0.005f;

    GameObject bottomMarker;
    GameObject topMarker;
    LineRenderer measureLine;

    void Awake()
    {
        var lineGo = new GameObject("MeasurementLine");
        measureLine = lineGo.AddComponent<LineRenderer>();
        measureLine.positionCount = 2;
        measureLine.startWidth = lineWidth;
        measureLine.endWidth = lineWidth;
        measureLine.useWorldSpace = true;
        // Use the line's default material and tint it — avoids null shader in URP/HDRP projects
        measureLine.material = new Material(measureLine.material) { color = Color.white };
        measureLine.enabled = false;
    }

    void OnEnable()
    {
        session.OnStateChanged += HandleStateChange;
        session.OnMeasurementComplete += HandleComplete;
    }

    void OnDisable()
    {
        session.OnStateChanged -= HandleStateChange;
        session.OnMeasurementComplete -= HandleComplete;
    }

    void HandleStateChange(MeasurementSession.State state)
    {
        if (state == MeasurementSession.State.Idle)
            ClearMarkers();

        if (state == MeasurementSession.State.BottomPlaced)
        {
            ClearMarkers();
            bottomMarker = CreateMarker(session.BottomPoint, new Color(0.2f, 0.9f, 0.2f));
        }
    }

    void HandleComplete(MeasurementResult result)
    {
        topMarker = CreateMarker(result.topPoint, new Color(1f, 0.6f, 0.1f));

        measureLine.enabled = true;
        measureLine.SetPosition(0, result.bottomPoint);
        measureLine.SetPosition(1, result.topPoint);
    }

    void ClearMarkers()
    {
        if (bottomMarker) Destroy(bottomMarker);
        if (topMarker)    Destroy(topMarker);
        measureLine.enabled = false;
    }

    static GameObject CreateMarker(Vector3 worldPos, Color color)
    {
        var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        go.transform.position = worldPos;
        go.transform.localScale = Vector3.one * 0.03f;  // 3 cm sphere
        go.name = "MeasurementMarker";
        Destroy(go.GetComponent<Collider>());           // don't block raycasts

        var rend = go.GetComponent<Renderer>();
        rend.material = new Material(rend.material) { color = color };
        return go;
    }
}
