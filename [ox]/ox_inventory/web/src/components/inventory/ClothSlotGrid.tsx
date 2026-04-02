// @ts-nocheck
import React, { useState } from 'react';
import { CLOTH_SLOTS, getClothImageUrl, ClothSlotDef, ClothSlotData, ClothSlotsState, GloveOption } from './clothSlots';
import { DragSource } from '../../typings';
import { useDrag, useDrop, useDragLayer } from 'react-dnd';
import { useAppDispatch, useAppSelector } from '../../store';
import { closeTooltip } from '../../store/tooltip';
import { Items } from '../../store/items';
import { fetchNui } from '../../utils/fetchNui';
import GloveModal from './GloveModal';
import { getItemRarityColor } from '../../store/rarity';
import { setSuppressItemNotification } from '../utils/ItemNotifications';
import { useDrag, useDrop, useDragLayer } from 'react-dnd';

const slotMap = (slots: ClothSlotDef[]): Record<number, ClothSlotDef> => {
  const map: Record<number, ClothSlotDef> = {};
  for (const s of slots) map[s.slot] = s;
  return map;
};

const LAYOUT = {
  left:   [11, 5, 4, 10, 7],
  center: [
    { slots: [1, 2], type: 'pair' },
    { slots: [3],    type: 'large' },
    { slots: [6],    type: 'large' },
  ],
  right:  [8, 9, 12, 13, 14],
};

const DECAL_SLOT = 15;

interface ClothSlotProps {
  def: ClothSlotDef;
  equipped: ClothSlotData | null;
  disabled?: boolean;
  large?: boolean;
  onGloveClick?: () => void;
  isHinted?: boolean;
}

const ClothSlot: React.FC<ClothSlotProps> = ({ def, equipped, disabled, large, onGloveClick, isHinted }) => {
  const dispatch = useAppDispatch();
  const hasItem = !!equipped;
  const isGlove = def.isGloveSelector;

  const imageUrl = hasItem
    ? getClothImageUrl(
        isGlove ? 'tay' : equipped.name,
        equipped.drawableId,
        equipped.textureId,
        equipped.gender
      )
    : '';

  const rarityColor = hasItem
    ? getItemRarityColor(isGlove ? def.itemName : equipped.name, {
        drawableId: equipped.drawableId,
        textureId: equipped.textureId,
        gender: equipped.gender,
      })
    : undefined;

  const [{ isDragging }, drag] = useDrag<DragSource, void, { isDragging: boolean }>(
    () => ({
      type: 'CLOTH_SLOT',
      collect: (monitor) => ({ isDragging: monitor.isDragging() }),
      item: () =>
        hasItem && !disabled && !isGlove
          ? {
              inventory: 'cloth-slot' as any,
              item: { name: equipped.name, slot: def.slot },
              image: imageUrl ? `url(${imageUrl})` : 'none',
            }
          : null,
      canDrag: () => hasItem && !disabled && !isGlove,
    }),
    [equipped, def, disabled]
  );

  const [{ isOver }, drop] = useDrop<DragSource, void, { isOver: boolean }>(
    () => ({
      accept: ['SLOT', 'BACKPACK_SLOT'],
      collect: (monitor) => ({ isOver: monitor.isOver() }),
      drop: (source) => {
        if (disabled || isGlove) return;
        dispatch(closeTooltip());

        setSuppressItemNotification(true);
        setTimeout(() => setSuppressItemNotification(false), 1000);

        if (source.inventory === 'backpack') {
          if (source.item.name !== def.itemName) return;
          fetchNui('clothSlotEquipFromBackpack', {
            fromSlot: source.item.slot,
            toClothSlot: def.slot,
          });
          return;
        }

        if (source.inventory !== 'player') return;
        if (source.item.name !== def.itemName) return;
        fetchNui('clothSlotEquip', {
          fromSlot: source.item.slot,
          toClothSlot: def.slot,
        });
      },
      canDrop: (source) => {
        if (disabled || isGlove) return false;
        if (source.inventory === 'backpack') {
          return source.item?.name === def.itemName;
        }
        return source.inventory === 'player' && source.item.name === def.itemName;
      },
    }),
    [equipped, def, disabled]
  );

  const connectRef = (el: HTMLDivElement | null) => {
    if (isGlove) return;
    drag(drop(el));
  };

  const handleClick = () => {
    if (isGlove && !disabled && onGloveClick) onGloveClick();
  };

  const showHint = isHinted && !disabled;

  return (
    <div
      ref={connectRef}
      className={`cloth-new-slot${large ? ' cloth-new-slot--large' : ''}${isGlove ? ' cloth-new-slot--glove' : ''}${showHint ? ' cloth-new-slot--hinted' : ''}`}
      data-rarity={rarityColor ? '' : undefined}
      style={{
        ...(rarityColor ? ({ '--rarity-color': rarityColor } as React.CSSProperties) : {}),
        opacity: disabled ? 0.35 : isDragging ? 0.4 : 1,
        filter: disabled ? 'grayscale(100%)' : undefined,
        cursor: disabled ? 'not-allowed' : isGlove ? 'pointer' : undefined,
        border: isOver && !disabled
          ? '1px dashed rgba(255,255,255,0.4)'
          : showHint
            ? '1px solid rgba(0, 255, 255, 0.4)'
            : undefined,
        boxShadow: showHint ? '0 0 6px 1px rgba(0, 255, 255, 0.2)' : undefined,
        transition: 'border 0.2s ease, box-shadow 0.2s ease',
      }}
      onClick={handleClick}
    >
      <div
        className="cloth-new-slot__image"
        style={{
          backgroundImage: hasItem ? `url(${imageUrl})` : `url(assets/icons/svg/${def.icon})`,
          opacity: hasItem ? 1 : showHint ? 0.35 : 0.15,
          backgroundSize: hasItem ? (large ? 'contain' : '68%') : (large ? '35%' : '45%'),
          filter: hasItem ? undefined : 'invert(1)',
          transition: 'opacity 0.2s ease',
        }}
      />
      <div className="cloth-new-slot__label">
        <span>{def.label}</span>
      </div>
    </div>
  );
};

const useDragHint = (): string | null => {
  return useDragLayer((monitor) => {
    if (!monitor.isDragging()) return null;
    const itemType = monitor.getItemType();
    if (itemType !== 'SLOT' && itemType !== 'BACKPACK_SLOT') return null;
    const source = monitor.getItem() as DragSource | null;
    if (!source?.item?.name) return null;
    return source.item.name;
  });
};

interface ClothSlotGridProps {
  clothSlots: ClothSlotsState;
  gloveOptions: GloveOption[];
  isFreemode?: boolean;
  hasDecalAccess?: boolean;
}

const ClothSlotGrid: React.FC<ClothSlotGridProps> = ({ clothSlots, gloveOptions, isFreemode = true, hasDecalAccess = false }) => {
  const isBusy = useAppSelector((state) => state.inventory.isBusy);
  const [showGloveModal, setShowGloveModal] = useState(false);
  const defs = slotMap(CLOTH_SLOTS);
  const draggedItemName = useDragHint();

  const [, gridDrop] = useDrop<DragSource, { consumed: boolean }, unknown>(
    () => ({
      accept: ['BACKPACK_SLOT'],
      drop: (_, monitor) => {
        if (monitor.didDrop()) return undefined;
        return { consumed: true };
      },
    }),
    []
  );

  const renderSlot = (slotNum: number, large?: boolean) => {
    const def = defs[slotNum];
    if (!def) return null;
    const isBackpackSlot = def.slot === 11;
    const disabled = !isFreemode && !isBackpackSlot;
    const isHinted = !!draggedItemName && def.itemName === draggedItemName;
    return (
      <ClothSlot
        key={`cloth-${def.slot}`}
        def={def}
        equipped={clothSlots[def.slot] || null}
        disabled={disabled}
        large={large}
        onGloveClick={() => setShowGloveModal(true)}
        isHinted={isHinted}
      />
    );
  };

  return (
    <div ref={gridDrop} className="cloth-layout" style={{ pointerEvents: isBusy ? 'none' : 'auto' }}>
      <div className="cloth-layout__col cloth-layout__col--side">
        {LAYOUT.left.map((s) => renderSlot(s))}
      </div>
      <div className="cloth-layout__col cloth-layout__col--center">
        <div className="cloth-layout__center-pair">
          {renderSlot(1)}
          {renderSlot(2)}
        </div>
        {renderSlot(3, true)}
        {renderSlot(6, true)}
      </div>
      <div className="cloth-layout__col cloth-layout__col--side">
        {LAYOUT.right.map((s) => renderSlot(s))}
      </div>

      {hasDecalAccess && (
        <div className="cloth-layout__decal">
          {renderSlot(DECAL_SLOT)}
        </div>
      )}

      {showGloveModal && isFreemode && (
        <GloveModal
          options={gloveOptions}
          currentEquipped={clothSlots[5] || null}
          onClose={() => setShowGloveModal(false)}
          gender={(() => {
            for (const slot of Object.values(clothSlots)) {
              if (slot?.gender !== undefined) return slot.gender;
            }
            return 0;
          })()}
        />
      )}
    </div>
  );
};

export default ClothSlotGrid;