using UnityEngine;
using System;

public class MeasurementSession : MonoBehaviour
{
    public enum State { Idle, BottomPlaced, Complete }

    public State CurrentState { get; private set; } = State.Idle;
    public Vector3 BottomPoint { get; private set; }
    public MeasurementResult LastResult { get; private set; }

    public event Action<State> OnStateChanged;
    public event Action<MeasurementResult> OnMeasurementComplete;

    public void RecordTap(Vector3 worldPoint)
    {
        switch (CurrentState)
        {
            case State.Idle:
                BottomPoint = worldPoint;
                Transition(State.BottomPlaced);
                break;

            case State.BottomPlaced:
                float vertical  = HeightCalculator.VerticalHeight(BottomPoint, worldPoint);
                float euclidean = HeightCalculator.EuclideanDistance(BottomPoint, worldPoint);
                LastResult = new MeasurementResult
                {
                    verticalHeight   = vertical,
                    euclideanDistance = euclidean,
                    category         = HeightCategory.Get(vertical),
                    bottomPoint      = BottomPoint,
                    topPoint         = worldPoint,
                    timestamp        = DateTime.Now,
                };
                Transition(State.Complete);
                OnMeasurementComplete?.Invoke(LastResult);
                break;

            case State.Complete:
                break;
        }
    }

    public void Reset()
    {
        LastResult = null;
        Transition(State.Idle);
    }

    void Transition(State next)
    {
        CurrentState = next;
        OnStateChanged?.Invoke(next);
    }
}
