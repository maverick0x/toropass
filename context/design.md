---
name: ToroID
colors:
  surface: '#fbf9fb'
  surface-dim: '#dbd9dc'
  surface-bright: '#fbf9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f6'
  surface-container: '#efedf0'
  surface-container-high: '#e9e7ea'
  surface-container-highest: '#e3e2e5'
  on-surface: '#1b1c1e'
  on-surface-variant: '#434656'
  inverse-surface: '#303033'
  inverse-on-surface: '#f2f0f3'
  outline: '#737688'
  outline-variant: '#c3c5d9'
  surface-tint: '#004ced'
  primary: '#003ec7'
  on-primary: '#ffffff'
  primary-container: '#0052ff'
  on-primary-container: '#dfe3ff'
  inverse-primary: '#b7c4ff'
  secondary: '#8433c4'
  on-secondary: '#ffffff'
  secondary-container: '#bd6efe'
  on-secondary-container: '#450073'
  tertiary: '#00585b'
  on-tertiary: '#ffffff'
  tertiary-container: '#007277'
  on-tertiary-container: '#7bf8ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b7c4ff'
  on-primary-fixed: '#001452'
  on-primary-fixed-variant: '#0038b6'
  secondary-fixed: '#f2daff'
  secondary-fixed-dim: '#e0b6ff'
  on-secondary-fixed: '#2e004e'
  on-secondary-fixed-variant: '#6a0baa'
  tertiary-fixed: '#63f7ff'
  tertiary-fixed-dim: '#00dce5'
  on-tertiary-fixed: '#002021'
  on-tertiary-fixed-variant: '#004f53'
  background: '#fbf9fb'
  on-background: '#1b1c1e'
  surface-variant: '#e3e2e5'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  display-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '500'
    lineHeight: '1.6'
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.4'
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.4'
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-padding-mobile: 24px
  container-padding-desktop: 40px
  gutter: 24px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
  section-gap: 64px
---

## Brand & Style

The design system is built on the duality of "Playful Precision." It bridges the gap between the complex, often intimidating world of Web3 and the everyday user by utilizing a **Soft-Tech Minimalism** aesthetic. 

The personality is energetic and welcoming, characterized by high-clarity layouts punctuated by vibrant accents and abstract 3D forms. To maintain a sense of security, the system relies on perfect mathematical spacing and high-quality typography, ensuring that "fun" never compromises "trust." The interface should feel like a premium physical object—smooth, tactile, and responsive.

**Visual Pillars:**
- **Clarity over Complexity:** Use white space as a functional tool to reduce cognitive load during cryptographic tasks.
- **Dynamic Stability:** Combine stable, grounded layouts with floating, iridescent 3D assets.
- **Human-Centric Tech:** Replace rigid industrial grids with soft, organic containers and friendly micro-interactions.

## Colors

This design system utilizes a high-vibrancy palette set against a clinical white canvas. 

- **Primary (Electric Blue):** The core action color, representing stability and the traditional "trust" of financial systems, but dialed up for the digital age.
- **Secondary (Neon Purple):** Used for "Web3 magic" moments—NFTs, wallet connections, and success states.
- **Tertiary (Cyber Teal):** Reserved for data visualizations and highlights.
- **Neutrals:** We use a "Deep Ink" (#0A0B0D) for text to ensure AAA contrast, while surfaces use ultra-light grays (#F5F7FA) to define boundaries without adding visual weight.
- **Gradients:** Use linear gradients (45°) transitioning from Electric Blue to Neon Purple for primary buttons and high-interest 3D elements.

## Typography

The typography strategy prioritizes readability and personality. **Plus Jakarta Sans** provides a modern, slightly rounded geometric feel that aligns with the "approachable" brand pillar. **Inter** is used for utility-heavy labels and data (like wallet addresses and transaction hashes) due to its exceptional legibility at small sizes.

Large display headings should use heavy weights and tight letter-spacing to create a "bold" impact. Body text remains airy with generous line-heights to ensure the app feels "minimal" even when presenting dense information.

## Layout & Spacing

This design system employs a **Fluid-Floating Layout**. Content is organized into distinct, soft-edged cards that appear to float on the background.

- **Grid:** On desktop, a 12-column grid with a maximum width of 1200px. On mobile, a single-column flow with 24px side margins.
- **Rhythm:** An 8px base unit drives all spacing. 
- **Hierarchy:** Use aggressive vertical spacing (Section Gaps) to separate distinct user intents (e.g., separating "Identity Management" from "Transaction History").
- **Safe Areas:** Cards and modals must maintain a minimum internal padding of 24px (sm) to 32px (lg) to accommodate the large corner radii.

## Elevation & Depth

Depth in this design system is achieved through **Soft Ambient Shadows** and **Selective Glassmorphism**. We avoid harsh lines in favor of volume.

- **The Ground:** The main background is pure white (#FFFFFF).
- **The Surface (Level 1):** Primary cards use a subtle "Air Shadow"—a very large blur (40px+) with low opacity (4-6%) colored with a hint of the primary blue.
- **The Highlight (Level 2):** Modals and dropdowns use a semi-transparent white background (80% opacity) with a 20px backdrop-blur to create a frosted glass effect.
- **The Interactive (Level 3):** On hover, elements should lift slightly (translate -4px Y-axis) and the shadow should become more diffused and slightly more opaque.

## Shapes

The shape language is the primary driver of the "approachable" feel. We use exaggerated corner radii to remove any sense of corporate rigidity.

- **Standard Containers:** All cards and primary containers must use a corner radius between **24px and 32px**.
- **Buttons:** Use fully rounded (pill-shaped) corners to encourage interaction and signify "touchability."
- **3D Elements:** Incorporate abstract, smooth-surfaced 3D shapes (spheres, toruses, and ribbons) with iridescent textures. These should have a "squishy" or "liquid" visual quality, appearing to float behind or around key UI cards.

## Components

**Buttons:**
- **Primary:** High-vibrancy Electric Blue background or Blue-to-Purple gradient. Text is white. Heavy drop shadow that matches the button color.
- **Secondary:** White background with a 1.5px border in Electric Blue. 
- **Interaction:** On press, buttons should scale down slightly (95%) to provide haptic-like feedback.

**Input Fields:**
- Backgrounds should be a soft gray (#F5F7FA). 
- Borders are invisible until focused; on focus, a 2px Electric Blue border appears with a soft outer glow.
- Labels sit above the field in `label-sm` (Inter).

**Identity Cards:**
- Special containers for user DID (Decentralized ID) information. These use the frosted glass (glassmorphism) effect with a subtle iridescent border-stroke.
- Feature a prominent 3D avatar or "Identity Orb" in the top corner.

**Status Chips:**
- Pill-shaped with low-opacity background tints (e.g., Success is 10% Green with 100% Green text).
- Use `label-sm` typography for high density.

**Progress Indicators:**
- Use thick, rounded-cap bars. For "Securing Identity" or "Verifying" states, use a shimmering "shimmer" animation across the bar.
