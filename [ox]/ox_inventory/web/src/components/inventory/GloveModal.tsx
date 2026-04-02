// @ts-nocheck
import React from 'react';
import { GloveOption, ClothSlotData, getClothImageUrl } from './clothSlots';
import { fetchNui } from '../../utils/fetchNui';

interface GloveModalProps {
  options: GloveOption[];
  currentEquipped: ClothSlotData | null;
  onClose: () => void;
  gender: number;
}

const GloveModal: React.FC<GloveModalProps> = ({ options, currentEquipped, onClose, gender }) => {
  const handleSelect = (opt: GloveOption) => {
    fetchNui('gloveSelect', { drawable: opt.drawable, texture: opt.texture });
    onClose();
  };

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) onClose();
  };

  const isSelected = (opt: GloveOption) => {
    return currentEquipped?.drawableId === opt.drawable && currentEquipped?.textureId === opt.texture;
  };

  return (
    <div className="glove-modal-backdrop" onClick={handleBackdropClick}>
      <div className="glove-modal">
        <div className="glove-modal-header">
          <span className="glove-modal-title">Chọn găng tay</span>
          <button className="glove-modal-close" onClick={onClose}>✕</button>
        </div>
        <div className="glove-modal-grid">
          {options.map((opt, idx) => {
            const imgUrl = getClothImageUrl('tay', opt.drawable, opt.texture, gender);
            const selected = isSelected(opt);
            return (
              <div
                key={`glove-${idx}`}
                className={`glove-modal-item ${selected ? 'glove-modal-item--selected' : ''}`}
                onClick={() => handleSelect(opt)}
                title={`Drawable: ${opt.drawable} | Texture: ${opt.texture}`}
              >
                <div
                  className="glove-modal-item-img"
                  style={{ backgroundImage: `url(${imgUrl})` }}
                />
                <span className="glove-modal-item-id">{opt.drawable}</span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default GloveModal;