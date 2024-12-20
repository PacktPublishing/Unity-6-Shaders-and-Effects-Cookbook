using UnityEngine;
using UnityEngine.EventSystems;

public class HighlightOnHover : MonoBehaviour, 
                                IPointerEnterHandler, 
                                IPointerExitHandler
{
    public Color highlightColor = Color.red;
    private Material material;

    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        OnPointerExit(null); // Turn off glow initially
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        material.SetColor("_HoverColor", highlightColor);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        material.SetColor("_HoverColor", Color.black);
    }
}
