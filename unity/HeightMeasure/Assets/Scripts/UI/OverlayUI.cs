using UnityEngine;
using UnityEngine.XR.ARFoundation;
using TMPro;

public class OverlayUI : MonoBehaviour
{
    [SerializeField] MeasurementSession session;
    [SerializeField] TextMeshProUGUI instructionText;
    [SerializeField] GameObject trackingWarningPanel;
    [SerializeField] TextMeshProUGUI trackingWarningText;

    void OnEnable()  => session.OnStateChanged += UpdateInstruction;
    void OnDisable() => session.OnStateChanged -= UpdateInstruction;

    void Update()
    {
        bool limited = ARSession.state == ARSessionState.SessionTracking
                    && ARSession.notTrackingReason != NotTrackingReason.None;

        trackingWarningPanel.SetActive(limited);
        if (limited)
            trackingWarningText.text = ReasonText(ARSession.notTrackingReason);
    }

    void UpdateInstruction(MeasurementSession.State state)
    {
        instructionText.text = state switch
        {
            MeasurementSession.State.Idle         => "Tap the bottom of the object",
            MeasurementSession.State.BottomPlaced => "Tap the top of the object",
            _                                     => string.Empty,
        };
    }

    static string ReasonText(NotTrackingReason reason) => reason switch
    {
        NotTrackingReason.Initializing         => "Initialising AR…",
        NotTrackingReason.ExcessiveMotion      => "Slow down — too much motion",
        NotTrackingReason.InsufficientFeatures => "Point at a textured surface",
        NotTrackingReason.Relocalizing         => "Relocalising…",
        _                                      => "Tracking limited",
    };
}
