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
        var state = ARSession.state;
        bool showWarning = state != ARSessionState.SessionTracking
                        && state != ARSessionState.None;

        trackingWarningPanel.SetActive(showWarning);
        if (showWarning)
            trackingWarningText.text = state switch
            {
                ARSessionState.Unsupported          => "AR not supported on this device",
                ARSessionState.CheckingAvailability => "Checking AR availability…",
                ARSessionState.NeedsInstall         => "AR services need to be installed",
                ARSessionState.Installing           => "Installing AR services…",
                ARSessionState.Ready                => "Initialising AR…",
                ARSessionState.SessionInitializing  => "Starting AR session…",
                _                                   => "AR tracking limited",
            };
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
}
