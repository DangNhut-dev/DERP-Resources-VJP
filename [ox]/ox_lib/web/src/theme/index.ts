import { MantineThemeOverride } from '@mantine/core';

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  fontFamily: 'Roboto',
  shadows: { sm: '1px 1px 3px rgba(0, 0, 0, 0.5)' },
  primaryColor: 'cyan',
  other: {
    accent: '#05F2F2',
    glass: {
      bg: 'rgba(0, 0, 0, 0.85)',
      border: 'rgba(255, 255, 255, 0.12)',
    },
    typeColors: {
      error: '#ff3b30',
      success: '#32d74b',
      warning: '#ff9d0a',
      info: '#05F2F2',
    },
  },
  components: {
    Button: {
      styles: {
        root: {
          border: 'none',
        },
      },
    },
    // === Input fields global styling ===
    TextInput: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&::placeholder': { color: 'rgba(255, 255, 255, 0.3)' },
          '&:focus': { borderColor: '#05F2F2' },
          '&:disabled': {
            backgroundColor: 'rgba(255, 255, 255, 0.02)',
            color: 'rgba(255, 255, 255, 0.35)',
            opacity: 1,
          },
        },
        icon: { color: '#05F2F2' },
      },
    },
    PasswordInput: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        innerInput: {
          color: '#FFFFFF',
          '&::placeholder': { color: 'rgba(255, 255, 255, 0.3)' },
        },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          '&:focus-within': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
      },
    },
    NumberInput: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&::placeholder': { color: 'rgba(255, 255, 255, 0.3)' },
          '&:focus': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
        control: { borderColor: 'rgba(255, 255, 255, 0.08)', color: '#FFFFFF' },
      },
    },
    Textarea: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&::placeholder': { color: 'rgba(255, 255, 255, 0.3)' },
          '&:focus': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
      },
    },
    Select: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&::placeholder': { color: 'rgba(255, 255, 255, 0.3)' },
          '&:focus': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
        dropdown: {
          backgroundColor: 'rgba(0, 0, 0, 0.9)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
        },
        item: {
          color: '#FFFFFF',
          '&[data-selected]': {
            backgroundColor: 'rgba(5, 242, 242, 0.15)',
            color: '#05F2F2',
          },
          '&[data-hovered]': {
            backgroundColor: 'rgba(255, 255, 255, 0.06)',
          },
        },
      },
    },
    MultiSelect: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&:focus-within': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
        dropdown: {
          backgroundColor: 'rgba(0, 0, 0, 0.9)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
        },
        item: {
          color: '#FFFFFF',
          '&[data-selected]': {
            backgroundColor: 'rgba(5, 242, 242, 0.15)',
            color: '#05F2F2',
          },
          '&[data-hovered]': {
            backgroundColor: 'rgba(255, 255, 255, 0.06)',
          },
        },
        value: {
          backgroundColor: 'rgba(5, 242, 242, 0.12)',
          border: '1px solid rgba(5, 242, 242, 0.25)',
          color: '#05F2F2',
        },
        defaultValueRemove: {
          color: '#05F2F2',
        },
        searchInput: {
          color: '#FFFFFF',
          '&::placeholder': { color: 'rgba(255, 255, 255, 0.3)' },
        },
      },
    },
    ColorInput: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&:focus': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
        dropdown: {
          backgroundColor: 'rgba(0, 0, 0, 0.9)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
        },
      },
    },
    DatePicker: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&:focus': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
        dropdown: {
          backgroundColor: 'rgba(0, 0, 0, 0.9)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
        },
        day: {
          color: '#FFFFFF',
          '&[data-selected]': {
            backgroundColor: 'rgba(5, 242, 242, 0.2)',
            color: '#05F2F2',
          },
          '&:hover': {
            backgroundColor: 'rgba(255, 255, 255, 0.06)',
          },
        },
      },
    },
    DateRangePicker: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&:focus': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
        dropdown: {
          backgroundColor: 'rgba(0, 0, 0, 0.9)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
        },
      },
    },
    TimeInput: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500, marginBottom: 4 },
        description: { color: 'rgba(255, 255, 255, 0.5)' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          color: '#FFFFFF',
          '&:focus-within': { borderColor: '#05F2F2' },
        },
        icon: { color: '#05F2F2' },
      },
    },
    Checkbox: {
      styles: {
        label: { color: '#FFFFFF' },
        input: {
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid rgba(255, 255, 255, 0.2)',
          '&:checked': {
            backgroundColor: 'rgba(5, 242, 242, 0.2)',
            borderColor: '#05F2F2',
          },
        },
        icon: { color: '#05F2F2' },
      },
    },
    Slider: {
      styles: {
        label: { color: '#05F2F2', fontWeight: 500 },
        track: { backgroundColor: 'rgba(255, 255, 255, 0.1)' },
        bar: { backgroundColor: '#05F2F2' },
        thumb: {
          backgroundColor: '#05F2F2',
          borderColor: '#05F2F2',
        },
        mark: { borderColor: 'rgba(255, 255, 255, 0.2)' },
        markFilled: { borderColor: '#05F2F2' },
        markLabel: { color: 'rgba(255, 255, 255, 0.5)', fontSize: 10 },
      },
    },
  },
};