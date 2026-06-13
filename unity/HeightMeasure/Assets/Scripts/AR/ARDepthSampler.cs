using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

/// Resolves a screen tap to a world-space 3D point.
///
/// On LiDAR-equipped iPhones (12 Pro+), ARMeshManager generates MeshColliders
/// from the LiDAR point cloud. Physics.Raycast against those colliders gives
/// sub-centimetre accuracy. On non-LiDAR devices the fallback uses
/// ARRaycastManager against detected planes (~5-15 cm accuracy).
[RequireComponent(typeof(ARRaycastManager))]
public class ARDepthSampler : MonoBehaviour
{
    [Tooltip("Layer(s) containing the AR mesh objects from ARMeshManager. Set to 'Everything' to raycast all layers.")]
    [SerializeField] LayerMask arMeshLayerMask = ~0;

    [SerializeField] float maxRaycastDistance = 10f;

    ARRaycastManager raycastManager;
    static readonly List<ARRaycastHit> arHits = new();

    void Awake() => raycastManager = GetComponent<ARRaycastManager>();

    public bool TryGetWorldPoint(Vector2 screenPosition, out Vector3 worldPoint)
    {
        worldPoint = Vector3.zero;

        // Primary: raycast against LiDAR mesh colliders (requires ARMeshManager in scene)
        var ray = Camera.main.ScreenPointToRay(screenPosition);
        if (Physics.Raycast(ray, out RaycastHit meshHit, maxRaycastDistance, arMeshLayerMask))
        {
            worldPoint = meshHit.point;
            return true;
        }

        // Fallback: AR Foundation feature points / estimated planes
        if (raycastManager.Raycast(screenPosition, arHits,
            TrackableType.FeaturePoint | TrackableType.PlaneEstimated))
        {
            worldPoint = arHits[0].pose.position;
            return true;
        }

        return false;
    }
}
