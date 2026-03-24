// Orla Kealy 18:00 PM 15/03/2026
// Description: Created filter option for charts
//              Added dropdown feature with checkboxes
//              Added a 'Select All' button
//              Add animations

// Orla Kealy 21:00 PM 21/03/2026
// Description: Improved code clarity and added comments

class chartMultiSelectFilter
{
    // Data
    String[] labels;
    int[] values;
    boolean[] selected;

    boolean changed = true;

    // Layout
    float x, y;
    float dropdownWidth = 180;
    float dropdownHeight = 200;
    float itemHeight = 22;
    float selectAllHeight = 25;
    
    // State
    boolean opened = false;
    String searchText = "";

    // Animation 
    float triangleRotation = 0;
    float triangleTarget = 0;

    float panelAnim = 0;

    float selectAllHoverAnim = 0;

    float[] labelHoverAnim;
    float[] itemAnim;
    
    float[] checkboxScale;
    float[] checkboxVelocity;


    chartMultiSelectFilter(String[] labels, int[] values, float x, float y)
    {
        this.labels = labels;
        this.values = values;
        this.x = x;
        this.y = y;
        
        int labelsLength = labels.length;

        selected = new boolean[labelsLength];
        labelHoverAnim = new float[labelsLength];
        checkboxScale = new float[labelsLength];
        checkboxVelocity = new float[labelsLength];
        itemAnim = new float[labelsLength];

        for (int i = 0; i < labelsLength; i++)
        {
            selected[i] = true;
            checkboxScale[i] = 1.0;
        }
    }

    // getVisibleIndices
    // Returns indices of labels that match the current search string
    ArrayList<Integer> getVisibleIndices()
    {
        ArrayList<Integer> visible = new ArrayList<Integer>();

        for (int i = 0; i < labels.length; i++)
        {
            if (searchText.equals("") || labels[i].toLowerCase().contains(searchText.toLowerCase()))
            {
                visible.add(i);
            }
        }

        return visible;
    }

    // drawFilter
    // Called from Charts.chartsDraw()
    // Main render method
    void drawFilter()
    {
        //Jesse Margarites, 12PM, 24/03, Fixing aesthetics
        pushStyle();
        textAlign(LEFT, CENTER);
        textSize(12);

        // Triangle animation
        if (opened)
        {
            triangleTarget = PI;
        }
        else
        {
            triangleTarget = 0;
        }

        triangleRotation = lerp(triangleRotation, triangleTarget, 0.25);

        // Dropdown panel animation
        float target;
        if (opened)
        {
            target = 1;
        }
        else
        {
            target = 0;
        }

        panelAnim = lerp(panelAnim, target, 0.18);

        // Header
        boolean hoveringHeader =
            mouseX > x && mouseX < x + dropdownWidth &&
            mouseY > y && mouseY < y + 20;

        if (hoveringHeader)
        {
            fill(220);
        }
        else
        {
            fill(255);
        }

        stroke(0);
        rect(x, y, dropdownWidth, 20);

        fill(0);
        text("Filter", x + 5, y + 10);

        // Triangle rotation
        float triX = x + dropdownWidth - 15;
        float triY = y + 10;

        pushMatrix();
        translate(triX, triY);
        rotate(triangleRotation);
        fill(0);
        noStroke();
        triangle(-5, -4, 5, -4, 0, 4);
        popMatrix();

        float animatedHeight = dropdownHeight * panelAnim;
        if (animatedHeight < 2) return;                    // exit if panel fully closed

        // Search box
        fill(255);
        stroke(0);
        rect(x, y + 20, dropdownWidth, 20);
        
        int blink = (millis()/500)%2;
        String displayText = "Search: " + searchText + (blink == 0 ? "|" : "");

        fill(120);
        text(displayText, x + 5, y + 30);

        // Panel background
        fill(245);
        stroke(0);
        rect(x, y + 40, dropdownWidth, animatedHeight);

        ArrayList<Integer> visible = getVisibleIndices();
        int maxVisibleItems = int((dropdownHeight - selectAllHeight)/itemHeight);
        float selectAllY = y + 40;

        // 'Select All' button
        if (panelAnim > 0.25)
        {
            boolean hoveringSelectAll =
                mouseX > x+5 && mouseX < x+dropdownWidth-5 &&
                mouseY > selectAllY && mouseY < selectAllY+selectAllHeight;

            selectAllHoverAnim = lerp(selectAllHoverAnim, hoveringSelectAll ? 1 : 0, 0.2);

            if (hoveringSelectAll)
            {
                fill(200);
            }
            else
            {
                fill(230);
            }

            rect(x + 5, selectAllY, dropdownWidth - 10, selectAllHeight);

            float size = lerp(12, 14, selectAllHoverAnim);
            textSize(size);

            fill(0);
            textAlign(CENTER, CENTER);
            text("Select All", x+dropdownWidth / 2, selectAllY+selectAllHeight / 2);

            textAlign(LEFT, CENTER);
        }

        // Item rows
        for (int i = 0; i < min(visible.size(), maxVisibleItems); i++)
        {
            int index = visible.get(i);

            float itemY = selectAllY + selectAllHeight + i * itemHeight;

            if (itemY + itemHeight > y + 40 + animatedHeight)
            {
                break;
            }

            // Stagger animation
            float delay = i * 0.06;
            float targetAnim;

            if (panelAnim > delay)
            {
                targetAnim = 1;
            }
            else 
            {
                targetAnim = 0;
            }

            itemAnim[index] = lerp(itemAnim[index], targetAnim, 0.25);
            float offset = (1 - itemAnim[index]) * -8;

            // Row hover highlight
            boolean hoveringItem =
                mouseX > x && mouseX < x+dropdownWidth &&
                mouseY > itemY && mouseY < itemY+itemHeight;

            if (hoveringItem)
            {
                fill(220);
                rect(x, itemY + offset, dropdownWidth, itemHeight);
            }

            labelHoverAnim[index] = lerp(labelHoverAnim[index], hoveringItem ? 1 : 0, 0.2);

            // Checkbox spring
            float targetScale;
            if (selected[index])
            {
                targetScale = 1;
            }
            else
            {
                targetScale = 0;
            }

            float stiffness = 0.35;
            float damping = 0.6;
            
            float force = (targetScale - checkboxScale[index]) * stiffness;
            checkboxVelocity[index] += force;
            checkboxVelocity[index] *= damping;

            checkboxScale[index] += checkboxVelocity[index];

            float checkX = x + 5;
            float checkY = itemY + (itemHeight - 14) / 2 + offset;

            pushMatrix();
            translate(checkX + 7, checkY + 7);

            float scaleVal = 1 + checkboxScale[index] * 0.15;
            scale(scaleVal);

            rectMode(CENTER);

            fill(255);
            stroke(0);
            rect(0, 0, 14, 14);

            // Draw tick mark, when selected
            if (selected[index])
            {
                line(-3,0,0,3);
                line(0,3,5,-4);
            }

            popMatrix();
            rectMode(CORNER);

            // Label
            float labelSize = lerp(12, 13.5, labelHoverAnim[index]);
            textSize(labelSize);

            fill(0);
            text(labels[index], x + 25, itemY + itemHeight / 2 + offset);
        }
        popStyle();
    }

    // mousePressed
    // Called by Charts.mousePressed()
    // Handles header toggle, outside-click close, select all and individual item toggling
    void mousePressed()
    {
        // Ignore clicks during animation
        if (panelAnim < 0.95 && opened)
        {
            return;
        }

        // Click outside open panel to close
        if (opened &&
            !(mouseX > x && mouseX < x + dropdownWidth &&
            mouseY > y && mouseY < y + 40 + dropdownHeight))
        {
            opened = false;
            return;
        }

        // Click on header to toggle open / close
        if (mouseX > x && mouseX < x + dropdownWidth &&
            mouseY > y && mouseY < y + 20)
        {
            opened = !opened;
            return;
        }

        if (!opened) 
        {
            return;
        }

        ArrayList<Integer> visible = getVisibleIndices();
        int maxVisibleItems = int((dropdownHeight-selectAllHeight)/itemHeight);

        float selectAllY = y + 40;

        // Click on 'Select All' to re-select everything and redraw chart
        if (mouseX > x + 5 && mouseX < x + dropdownWidth - 5 &&
           mouseY > selectAllY && mouseY < selectAllY + selectAllHeight)
        {
            for (int i = 0; i < selected.length;i++)
            {
                selected[i]=true;
            }

            changed = true;
            return;
        }

        // Click on an item row to toggle and redraw chart
        for(int i = 0; i < min(visible.size(), maxVisibleItems);i++)
        {
            int index = visible.get(i);

            float itemY = selectAllY + selectAllHeight + i * itemHeight;

            if (mouseX > x && mouseX < x + dropdownWidth && 
               mouseY > itemY && mouseY < itemY + itemHeight)
            {
                selected[index] = !selected[index];
                changed = true;
            }
        }
    }
    
    
    // keyPressed
    // Called by Charts.keyPressed()
    // Appends characters to search string and handles backspace - ignored when panel is closed
    void keyPressed(char key)
    {
        if (!opened) 
        { 
            return;
        }

        if (key == BACKSPACE && searchText.length() > 0)
        {
            searchText = searchText.substring(0, searchText.length() - 1);
        }
        else if (key >= 32 && key <= 126)
        {
            searchText += key;
        }
    }

    // getFilteredLabels
    // Returns labels whose selected flag is true
    String[] getFilteredLabels()
    {
        ArrayList<String> filtered = new ArrayList<String>();

        for (int i = 0; i < labels.length; i++)
            if (selected[i])
            {
                filtered.add(labels[i]);
            }

        return filtered.toArray(new String[0]);
    }

    // getFilteredValues
    // Returns values whose selected flag is true - same order as getFilteredLabels (aligned)
    int[] getFilteredValues()
    {
        ArrayList<Integer> filtered = new ArrayList<Integer>();

        for (int i = 0; i < values.length; i++)
        {
            if (selected[i])
            {
                filtered.add(values[i]);
            }
        }

        int[] result = new int[filtered.size()];

        for (int i = 0; i < result.length; i++)
        {
            result[i] = filtered.get(i);
        }

        return result;
    }
}