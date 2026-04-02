// components/inventory/GiveModal.tsx
// @ts-nocheck
import React, { useState, useEffect, useRef } from 'react';
import { SlotWithItem } from '../../typings';
import { Items } from '../../store/items';
import { getItemUrl } from '../../helpers';
import { fetchNui } from '../../utils/fetchNui';

interface GiveModalProps {
  item: SlotWithItem;
  onClose: () => void;
}

const GiveModal: React.FC<GiveModalProps> = ({ item, onClose }) => {
  const maxCount = item.count || 1;
  const [count, setCount] = useState(maxCount);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    // Auto focus input khi mở
    setTimeout(() => inputRef.current?.focus(), 50);
  }, []);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        onClose();
      } else if (e.key === 'Enter') {
        e.preventDefault();
        handleConfirm();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [count]);

  const handleConfirm = () => {
    const finalCount = Math.max(1, Math.min(count, maxCount));
    fetchNui('giveItem', { slot: item.slot, count: finalCount });
    onClose();
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = parseInt(e.target.value);
    if (isNaN(val) || val < 1) {
      setCount(1);
    } else if (val > maxCount) {
      setCount(maxCount);
    } else {
      setCount(val);
    }
  };

  const handleBackdrop = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) onClose();
  };

  const label = item.metadata?.label || Items[item.name]?.label || item.name;
  const imageUrl = getItemUrl(item) || 'none';

  return (
    <div className="give-modal-backdrop" onClick={handleBackdrop}>
      <div className="give-modal">
        {/* Item preview */}
        <div className="give-modal-item-preview">
          <div
            className="give-modal-item-image"
            style={{ backgroundImage: `url(${imageUrl})` }}
          />
          <div className="give-modal-item-info">
            <span className="give-modal-item-name">{label}</span>
            <span className="give-modal-item-count">Đang có: {maxCount}x</span>
          </div>
        </div>

        {/* Input */}
        <div className="give-modal-input-wrapper">
          <label className="give-modal-label">Số lượng</label>
          <div className="give-modal-input-row">
            <button
              className="give-modal-btn-adjust"
              onClick={() => setCount(Math.max(1, count - 1))}
              disabled={count <= 1}
            >
              −
            </button>
            <input
              ref={inputRef}
              className="give-modal-input"
              type="number"
              value={count}
              onChange={handleChange}
              min={1}
              max={maxCount}
            />
            <button
              className="give-modal-btn-adjust"
              onClick={() => setCount(Math.min(maxCount, count + 1))}
              disabled={count >= maxCount}
            >
              +
            </button>
          </div>
        </div>

        {/* Actions */}
        <div className="give-modal-actions">
          <button className="give-modal-btn-cancel" onClick={onClose}>
            Hủy
          </button>
          <button className="give-modal-btn-confirm" onClick={handleConfirm}>
            Xác Nhận
          </button>
        </div>
      </div>
    </div>
  );
};

export default GiveModal;