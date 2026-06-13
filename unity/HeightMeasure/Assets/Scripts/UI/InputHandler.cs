using UnityEngine;

public class InputHandler : MonoBehaviour
{
    [SerializeField] ARDepthSampler depthSampler;
    [SerializeField] MeasurementSession session;

    void Update()
    {
        if (session.CurrentState == MeasurementSession.State.Complete) return;

        if (Input.touchCount > 0)
        {
            var touch = Input.GetTouch(0);
            if (touch.phase == TouchPhase.Began)
                HandleTap(touch.position);
        }
#if UNITY_EDITOR
        else if (Input.GetMouseButtonDown(0))
        {
            HandleTap(Input.mousePosition);
        }
#endif
    }

    void HandleTap(Vector2 screenPosition)
    {
        if (depthSampler.TryGetWorldPoint(screenPosition, out Vector3 worldPoint))
        {
            Handheld.Vibrate();
            session.RecordTap(worldPoint);
        }
    }
}
