---
name: Trusted Home Support System
colors:
  surface: '#f5faff'
  surface-dim: '#cfdce6'
  surface-bright: '#f5faff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eaf5ff'
  surface-container: '#e3f0fa'
  surface-container-high: '#ddeaf5'
  surface-container-highest: '#d7e4ef'
  on-surface: '#111d25'
  on-surface-variant: '#40484c'
  inverse-surface: '#26323a'
  inverse-on-surface: '#e6f2fd'
  outline: '#70787c'
  outline-variant: '#bfc8cc'
  surface-tint: '#1c667b'
  primary: '#004656'
  on-primary: '#ffffff'
  primary-container: '#0f5f73'
  on-primary-container: '#95d7ee'
  inverse-primary: '#8fd0e7'
  secondary: '#2e685d'
  on-secondary: '#ffffff'
  secondary-container: '#b0ebdd'
  on-secondary-container: '#336c61'
  tertiary: '#543c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#725200'
  on-tertiary-container: '#f8c662'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b4ebff'
  primary-fixed-dim: '#8fd0e7'
  on-primary-fixed: '#001f28'
  on-primary-fixed-variant: '#004e5f'
  secondary-fixed: '#b3eee0'
  secondary-fixed-dim: '#98d2c4'
  on-secondary-fixed: '#00201b'
  on-secondary-fixed-variant: '#115045'
  tertiary-fixed: '#ffdea4'
  tertiary-fixed-dim: '#f0bf5c'
  on-tertiary-fixed: '#261900'
  on-tertiary-fixed-variant: '#5d4200'
  background: '#f5faff'
  on-background: '#111d25'
  surface-variant: '#d7e4ef'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Source Sans 3
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Source Sans 3
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Source Sans 3
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base-unit: 4px
  container-margin: 20px
  gutter-md: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
  stack-xl: 48px
---

## Brand & Style
The brand personality centers on absolute reliability and professional warmth. It is designed for a hyperlocal marketplace where safety and high-caliber service are the primary consumer concerns. The design style follows a **Corporate / Modern** aesthetic with a **Tactile** touch—utilizing soft depth and organic warmth to differentiate from sterile, tech-heavy competitors.

The UI should evoke a sense of "quiet confidence." It avoids aggressive marketing tactics in favor of a sophisticated, editorial layout that highlights provider quality. Every interaction should feel intentional and grounded, reinforcing the "Verified" nature of the platform.

## Colors
The palette is rooted in the earth and sea to establish psychological safety.
- **Deep Teal-Blue (Primary):** Used for primary actions, headers, and brand identification. It represents authority and stability.
- **Midnight Slate (Dark Anchor):** Used for navigation bars and heavy structural elements to provide a sense of permanence.
- **Warm Mist (Background):** A non-white, off-white base that feels more premium and approachable than clinical pure white.
- **Sage Teal (Secondary):** Used for success states, secondary buttons, and active status indicators.
- **Muted Gold (Premium Accent):** Strictly reserved for "Elite" badges, "Verified" checkmarks, and high-tier subscription features.
- **Charcoal Ink:** The primary reading color, offering high legibility without the harshness of pure black.

## Typography
The system uses a pairing of **Manrope** for structure and **Source Sans 3** for reading. Manrope provides a modern, geometric balance for headings that feels professional yet contemporary. Source Sans 3 is utilized for its exceptional legibility in long-form descriptions and data-heavy provider profiles.

To maintain hierarchy on mobile:
- Large headlines should use negative letter-spacing to feel tighter and more premium.
- Labels use Manrope's bolder weights to distinguish them clearly from body text.
- Use `headline-lg` for mobile page titles, reserving `headline-xl` only for significant onboarding or hero moments.

## Layout & Spacing
This design system utilizes a **Fixed Grid** logic for mobile devices, based on a 4-column system for content and a 20px safe-margin on the outer edges of the screen.

The spacing rhythm follows a 4px baseline, but defaults to 8px increments for most components. 
- **Vertical Rhythm:** Elements within a card use `stack-sm`. Cards within a list use `stack-md`. Major sections (e.g., "Top Rated" vs "Near You") are separated by `stack-xl`.
- **Touch Targets:** No interactive element should have a height smaller than 44px to ensure accessibility for all users.

## Elevation & Depth
Depth is conveyed through **Tonal Layering** supplemented by **Ambient Shadows**. 

- **Surface Level 0 (Background):** Warm Mist (#F6F4EF).
- **Surface Level 1 (Cards/Inputs):** Pure White (#FFFFFF). This creates a subtle lift against the off-white background.
- **Shadows:** Use a "Soft Stone" tinted shadow. For standard provider cards: `0px 4px 12px rgba(30, 42, 50, 0.08)`. For floating buttons or active modals: `0px 12px 24px rgba(30, 42, 50, 0.12)`.
- **Borders:** Use a 1px border of "Soft Stone" (#D9D6CF) on level-1 surfaces to define edges without adding heavy visual weight.

## Shapes
The shape language is "Softly Geometric." A standard radius of **8px to 12px** is used to balance professional rigor with friendly approachability.

- **Small Components (Chips/Badges):** 4px to 6px radius.
- **Standard Components (Buttons/Inputs):** 8px radius.
- **Large Components (Provider Cards/Modals):** 12px to 16px radius for a more modern, containerized look.
- **Avatars:** Always circular to emphasize the human element of the service.

## Components
- **Buttons:** Primary buttons use Deep Teal-Blue with white text. Secondary buttons use a Soft Stone background with Charcoal Ink text. Avoid "Ghost" buttons for primary actions to maintain clear hierarchy.
- **Provider Cards:** The centerpiece of the system. They must include a circular avatar, a Sage Teal "Available" indicator, and a Muted Gold "Verified" badge. Information is stacked vertically with clear `label-sm` descriptors.
- **Chips:** Used for service categories (e.g., "Plumbing", "Electrical"). These should have a light Deep Teal-Blue tint background (#0F5F73 at 10% opacity) with Primary colored text.
- **Input Fields:** Use level-1 white surfaces with a Soft Stone border. On focus, the border transitions to Deep Teal-Blue with a 2px thickness.
- **Trust Signals:** Specialized "Trust Bar" components that highlight background checks or insurance status, using the Muted Gold accent color for the icons.
- **Navigation:** A bottom navigation bar in Midnight Slate with active states highlighted in Sage Teal.
