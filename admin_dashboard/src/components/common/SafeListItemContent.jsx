import React from 'react';

/**
 * SafeListItemContent - A utility component to create safe content for ListItemText
 * This prevents DOM nesting warnings by ensuring we use inline elements instead of block elements
 */

export const SafeListPrimary = ({ children, style = {} }) => (
  <span style={{ display: 'flex', alignItems: 'center', gap: '8px', ...style }}>
    {children}
  </span>
);

export const SafeListSecondary = ({ children, style = {} }) => (
  <span style={style}>
    {children}
  </span>
);

export const SafeListText = ({ children, variant = 'body2', style = {} }) => {
  const variantStyles = {
    h6: { fontSize: '1.25rem', fontWeight: 600 },
    subtitle1: { fontSize: '1rem', fontWeight: 500 },
    subtitle2: { fontSize: '0.875rem', fontWeight: 600 },
    body1: { fontSize: '1rem', fontWeight: 400 },
    body2: { fontSize: '0.875rem', fontWeight: 400 },
    caption: { fontSize: '0.75rem', fontWeight: 400 },
  };

  return (
    <span style={{ ...variantStyles[variant], ...style }}>
      {children}
    </span>
  );
};

export const SafeListBlock = ({ children, style = {} }) => (
  <span style={{ display: 'block', ...style }}>
    {children}
  </span>
);

/**
 * Usage Examples:
 * 
 * <ListItemText
 *   primary={
 *     <SafeListPrimary>
 *       <SafeListText variant="subtitle2">Main Text</SafeListText>
 *       <Chip label="Status" />
 *     </SafeListPrimary>
 *   }
 *   secondary={
 *     <SafeListSecondary>
 *       <SafeListBlock style={{ color: 'var(--color-textSecondary)' }}>
 *         Description text
 *       </SafeListBlock>
 *       <SafeListBlock style={{ color: 'var(--color-textSecondary)', fontSize: '0.75rem' }}>
 *         Timestamp
 *       </SafeListBlock>
 *     </SafeListSecondary>
 *   }
 * />
 */