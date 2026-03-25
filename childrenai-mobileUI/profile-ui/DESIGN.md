# Design System: Creative Intelligence for Young Minds

## 1. Overview & Creative North Star
**The Creative North Star: "The Living Playground"**

This design system rejects the "stiff classroom" aesthetic in favor of an immersive, tactile environment. We are moving beyond standard educational portals to create a space that feels like a premium, physical playset. By combining high-end editorial layouts with a child-friendly soul, we treat young users as capable creators.

The system breaks the "template" look through:
*   **Intentional Asymmetry:** Using the Spacing Scale (e.g., `12` vs `8`) to create dynamic, off-center focal points that feel organic.
*   **Layered Surfaces:** Overlapping cards and floating "glass" panels that suggest depth and play.
*   **High-Contrast Typography Scale:** Dramatically oversized `display-lg` headlines paired with generous white space to make "Talking to AI" feel like a grand adventure.

## 2. Colors
Our palette is vibrant yet sophisticated, utilizing Material Design tokens to ensure harmony between "fun" and "functional."

*   **Primary (`#0058bc`) & Primary Container (`#6d9fff`):** Our "Logic Blue." Use for core actions and AI interactions.
*   **Secondary (`#765600`) & Secondary Container (`#ffca57`):** "Spark Yellow." Used for moments of discovery and "aha!" insights.
*   **Tertiary (`#1e6a00`) & Tertiary Container (`#84fe58`):** "Growth Green." Reserved for success states and creative completion.

### The "No-Line" Rule
**Prohibit 1px solid borders for sectioning.** Boundaries must be defined solely through background color shifts. To separate a workspace from a sidebar, use `surface-container-low` against a `surface` background. This creates a soft-touch UI that feels molded rather than constructed.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked sheets of fine paper.
*   **Base:** `surface` (#f7f5ff)
*   **Sectioning:** `surface-container` (#e4e7ff)
*   **Active Interaction Area:** `surface-container-highest` (#d5dbff)
*   **Floating Cards:** `surface-container-lowest` (#ffffff) to create a "lifted" appearance.

### The "Glass & Gradient" Rule
To add professional polish, use **Glassmorphism** for floating toolbars or AI "chat bubbles." Use `surface_container_low` at 80% opacity with a `backdrop-blur` of 20px. For main CTAs, apply a subtle linear gradient from `primary` to `primary_container` at a 135-degree angle to give the button "soul" and dimension.

## 3. Typography
We utilize a dual-font strategy to balance character with extreme legibility.

*   **Display & Headlines (Plus Jakarta Sans):** A modern, geometric sans-serif with a high x-height. Use `display-lg` (3.5rem) for welcoming the student and `headline-md` (1.75rem) for section titles. The wide apertures of Plus Jakarta Sans make it incredibly friendly and readable for early readers.
*   **Body & Titles (Lexend):** Specifically designed to reduce visual stress and improve reading proficiency. All instructional text must use `body-lg` (1rem).
*   **Hierarchy Note:** Use `title-lg` (1.375rem) in `primary` color to highlight the "AI's voice," distinguishing it from the "System's voice" in `on_surface`.

## 4. Elevation & Depth
Depth in this system is achieved through **Tonal Layering**, not structural lines.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` background. The shift in luminance provides all the affordance a child needs to understand "tappability."
*   **Ambient Shadows:** For "floating" AI avatars or robots, use extra-diffused shadows.
    *   *Spec:* `0px 20px 40px rgba(36, 44, 81, 0.06)`. The shadow color is a 6% opacity version of `on_surface`, mimicking natural light.
*   **The "Ghost Border" Fallback:** If a container is placed on a background of the same color, use a "Ghost Border": `outline-variant` (#a3abd7) at **15% opacity**. Never use 100% opaque borders.

## 5. Components

### Buttons (The "Tactile" Interaction)
*   **Primary:** Rounded `xl` (3rem), `primary` background, `on_primary` text. Use a subtle inner-shadow (top-down) to make it look like a physical button.
*   **Secondary:** Rounded `xl`, `secondary_container` background. No border.

### AI Conversation Bubbles (The "Glass" Component)
*   Use `surface_container_lowest` with a `lg` (2rem) corner radius.
*   Apply a `surface-variant` "Ghost Border" at 20% opacity.
*   When the AI is "thinking," use a pulse animation on the container's `surface_dim` background.

### Cards & Coding Blocks
*   **Forbid dividers.** Use `3` (1rem) or `4` (1.4rem) spacing from the Spacing Scale to separate content.
*   Coding blocks should use `primary_container` for "Commands" and `tertiary_container` for "Logic," with `md` (1.5rem) rounded corners.

### Interactive Robot Avatar
*   Floating element utilizing the **Ambient Shadow** spec.
*   The avatar should always sit partially overlapping two surface tiers (e.g., half on `surface`, half on `surface-container-high`) to break the grid and create a 3D feel.

## 6. Do's and Don'ts

### Do:
*   **Do** use the `lg` (2rem) and `xl` (3rem) corner radius for any element a child is expected to touch.
*   **Do** use asymmetrical margins (e.g., `12` on the left, `16` on the right) for hero sections to create a "scrapbook" feel.
*   **Do** use `on_surface_variant` for helper text to keep the interface soft and approachable.

### Don't:
*   **Don't** use "Professional Jargon." Instead of "Execute Script," use "Tell the Robot to Go!"
*   **Don't** use pure black (#000000) for text. Use `on_surface` (#242c51) to maintain a premium, soft-contrast look.
*   **Don't** use 1px dividers. If you need to separate content, use a `1.5` (0.5rem) vertical gap or a subtle background shift.
*   **Don't** use "sharp" corners. The minimum radius allowed is `sm` (0.5rem) for the smallest of utility icons.