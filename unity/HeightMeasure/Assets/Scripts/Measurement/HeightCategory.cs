using UnityEngine;

[System.Serializable]
public class HeightCategory
{
    public string id;
    public string label;
    public float minMetres;
    public float maxMetres;
    public Color color;
    public string icon;

    public bool Contains(float height) => height >= minMetres && height < maxMetres;

    public static HeightCategory[] Defaults => new[]
    {
        new HeightCategory { id = "micro",  label = "Micro",           minMetres = 0f,    maxMetres = 0.10f, color = Color.gray,                icon = "●" },
        new HeightCategory { id = "small",  label = "Small",           minMetres = 0.10f, maxMetres = 0.30f, color = Color.green,               icon = "▪" },
        new HeightCategory { id = "medium", label = "Medium",          minMetres = 0.30f, maxMetres = 1.00f, color = new Color(0.2f, 0.5f, 1f), icon = "◆" },
        new HeightCategory { id = "tall",   label = "Tall",            minMetres = 1.00f, maxMetres = 2.00f, color = new Color(1f, 0.6f, 0.1f), icon = "▲" },
        new HeightCategory { id = "large",  label = "Large Structure", minMetres = 2.00f, maxMetres = 999f,  color = Color.red,                 icon = "⬛" },
    };

    public static HeightCategory Get(float height, HeightCategory[] categories = null)
    {
        var cats = categories ?? Defaults;
        foreach (var c in cats)
            if (c.Contains(height)) return c;
        return cats[cats.Length - 1];
    }
}
