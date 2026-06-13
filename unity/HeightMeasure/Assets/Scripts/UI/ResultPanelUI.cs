using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ResultPanelUI : MonoBehaviour
{
    [SerializeField] MeasurementSession session;
    [SerializeField] GameObject panel;
    [SerializeField] TextMeshProUGUI heightText;
    [SerializeField] TextMeshProUGUI categoryText;
    [SerializeField] Image categoryBackground;
    [SerializeField] GameObject slantRow;
    [SerializeField] TextMeshProUGUI slantText;
    [SerializeField] Button measureAgainButton;

    void OnEnable()
    {
        session.OnMeasurementComplete += ShowResult;
        session.OnStateChanged        += HandleStateChange;
        measureAgainButton.onClick.AddListener(session.Reset);
    }

    void OnDisable()
    {
        session.OnMeasurementComplete -= ShowResult;
        session.OnStateChanged        -= HandleStateChange;
        measureAgainButton.onClick.RemoveListener(session.Reset);
    }

    void ShowResult(MeasurementResult result)
    {
        panel.SetActive(true);
        heightText.text    = $"{result.verticalHeight:F2} m";
        categoryText.text  = $"{result.category.icon}  {result.category.label}";
        categoryBackground.color = result.category.color;

        slantRow.SetActive(result.ShowsSlantDistance);
        if (result.ShowsSlantDistance)
            slantText.text = $"Slant: {result.euclideanDistance:F2} m";
    }

    void HandleStateChange(MeasurementSession.State state)
    {
        if (state == MeasurementSession.State.Idle)
            panel.SetActive(false);
    }
}
