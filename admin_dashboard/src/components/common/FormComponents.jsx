import React, { useState } from 'react';
import { useTheme } from '../../contexts/ThemeContext.jsx';
import './FormComponents.css';

export const FloatingInput = ({ 
  label, 
  type = 'text', 
  value, 
  onChange, 
  error, 
  helperText,
  required = false,
  disabled = false,
  ...props 
}) => {
  const [isFocused, setIsFocused] = useState(false);
  const { colors } = useTheme();
  
  const hasValue = value && value.length > 0;
  const shouldFloat = isFocused || hasValue;

  const inputClass = `
    floating-input
    ${error ? 'floating-input-error' : ''}
    ${disabled ? 'floating-input-disabled' : ''}
  `.trim();

  const labelClass = `
    floating-label
    ${shouldFloat ? 'floating-label-float' : ''}
    ${error ? 'floating-label-error' : ''}
    ${isFocused ? 'floating-label-focused' : ''}
  `.trim();

  return (
    <div className="floating-input-container">
      <div className="floating-input-wrapper">
        <input
          type={type}
          value={value}
          onChange={onChange}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          className={inputClass}
          disabled={disabled}
          placeholder=" "
          {...props}
        />
        <label className={labelClass}>
          {label}
          {required && <span className="required-asterisk">*</span>}
        </label>
        <div className="floating-input-border"></div>
      </div>
      {(error || helperText) && (
        <div className={`floating-input-helper ${error ? 'helper-error' : ''}`}>
          {error || helperText}
        </div>
      )}
    </div>
  );
};

export const ModernButton = ({ 
  children, 
  variant = 'primary', 
  size = 'medium',
  loading = false,
  disabled = false,
  onClick,
  startIcon,
  endIcon,
  fullWidth = false,
  ...props 
}) => {
  const buttonClass = `
    modern-button
    modern-button-${variant}
    modern-button-${size}
    ${loading ? 'modern-button-loading' : ''}
    ${disabled ? 'modern-button-disabled' : ''}
    ${fullWidth ? 'modern-button-full-width' : ''}
  `.trim();

  return (
    <button
      className={buttonClass}
      onClick={onClick}
      disabled={disabled || loading}
      {...props}
    >
      {loading && <div className="button-spinner"></div>}
      {!loading && startIcon && <span className="button-icon-start">{startIcon}</span>}
      <span className="button-text">{children}</span>
      {!loading && endIcon && <span className="button-icon-end">{endIcon}</span>}
      <div className="button-ripple"></div>
    </button>
  );
};

export const ModernSelect = ({ 
  label, 
  value, 
  onChange, 
  options = [], 
  error, 
  helperText,
  required = false,
  disabled = false,
  placeholder = 'Select an option...',
  ...props 
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [isFocused, setIsFocused] = useState(false);
  
  const hasValue = value !== null && value !== undefined && value !== '';
  const shouldFloat = isFocused || hasValue || isOpen;
  
  const selectedOption = options.find(option => option.value === value);
  const displayValue = selectedOption ? selectedOption.label : '';

  const selectClass = `
    modern-select
    ${error ? 'modern-select-error' : ''}
    ${disabled ? 'modern-select-disabled' : ''}
    ${isOpen ? 'modern-select-open' : ''}
  `.trim();

  const labelClass = `
    modern-select-label
    ${shouldFloat ? 'modern-select-label-float' : ''}
    ${error ? 'modern-select-label-error' : ''}
    ${isFocused || isOpen ? 'modern-select-label-focused' : ''}
  `.trim();

  const handleSelect = (option) => {
    onChange({ target: { value: option.value } });
    setIsOpen(false);
    setIsFocused(false);
  };

  return (
    <div className="modern-select-container">
      <div className="modern-select-wrapper">
        <div
          className={selectClass}
          onClick={() => !disabled && setIsOpen(!isOpen)}
          onFocus={() => setIsFocused(true)}
          onBlur={() => {
            setTimeout(() => {
              setIsFocused(false);
              setIsOpen(false);
            }, 200);
          }}
          tabIndex={disabled ? -1 : 0}
        >
          <span className="modern-select-value">
            {displayValue || (!shouldFloat ? placeholder : '')}
          </span>
          <span className={`modern-select-arrow ${isOpen ? 'arrow-up' : 'arrow-down'}`}>
            ▼
          </span>
        </div>
        <label className={labelClass}>
          {label}
          {required && <span className="required-asterisk">*</span>}
        </label>
        <div className="modern-select-border"></div>
        
        {isOpen && (
          <div className="modern-select-dropdown">
            {options.length > 0 ? (
              options.map((option, index) => (
                <div
                  key={option.value || index}
                  className={`select-option ${option.value === value ? 'option-selected' : ''}`}
                  onClick={() => handleSelect(option)}
                >
                  {option.label}
                </div>
              ))
            ) : (
              <div className="select-option select-no-options">No options available</div>
            )}
          </div>
        )}
      </div>
      {(error || helperText) && (
        <div className={`modern-select-helper ${error ? 'helper-error' : ''}`}>
          {error || helperText}
        </div>
      )}
    </div>
  );
};

export const ModernTextarea = ({ 
  label, 
  value, 
  onChange, 
  error, 
  helperText,
  required = false,
  disabled = false,
  rows = 4,
  ...props 
}) => {
  const [isFocused, setIsFocused] = useState(false);
  
  const hasValue = value && value.length > 0;
  const shouldFloat = isFocused || hasValue;

  const textareaClass = `
    modern-textarea
    ${error ? 'modern-textarea-error' : ''}
    ${disabled ? 'modern-textarea-disabled' : ''}
  `.trim();

  const labelClass = `
    modern-textarea-label
    ${shouldFloat ? 'modern-textarea-label-float' : ''}
    ${error ? 'modern-textarea-label-error' : ''}
    ${isFocused ? 'modern-textarea-label-focused' : ''}
  `.trim();

  return (
    <div className="modern-textarea-container">
      <div className="modern-textarea-wrapper">
        <textarea
          value={value}
          onChange={onChange}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          className={textareaClass}
          disabled={disabled}
          rows={rows}
          placeholder=" "
          {...props}
        />
        <label className={labelClass}>
          {label}
          {required && <span className="required-asterisk">*</span>}
        </label>
        <div className="modern-textarea-border"></div>
      </div>
      {(error || helperText) && (
        <div className={`modern-textarea-helper ${error ? 'helper-error' : ''}`}>
          {error || helperText}
        </div>
      )}
    </div>
  );
};