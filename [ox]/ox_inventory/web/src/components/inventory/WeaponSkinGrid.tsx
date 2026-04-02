import React, { useRef } from 'react';
import { useAppSelector } from '../../store';
import { fetchNui } from '../../utils/fetchNui';
import { useDrag, useDrop } from 'react-dnd';
import { getItemUrl } from '../../helpers';
import { Items } from '../../store/items';
import type { DragSource } from '../../typings';
import { setSuppressItemNotification } from '../utils/ItemNotifications';
import { getItemRarityColor } from '../../store/rarity';

export interface WeaponSkinSlotData {
  item: string;
  weapon: string;
  label: string;
  image?: string;
}

export type WeaponSkinSlotsState = Record<number, WeaponSkinSlotData>;

interface WeaponSkinGridProps {
  skinSlots: WeaponSkinSlotsState;
}

const TOTAL_SLOTS = 25;

interface SkinSlotProps {
  slotIndex: number;
  data: WeaponSkinSlotData | undefined;
}

const WeaponSkinSlot: React.FC<SkinSlotProps> = ({ slotIndex, data }) => {
  const dataRef = useRef(data);
  dataRef.current = data;

  const fakeSlot = data ? { name: data.item, slot: slotIndex } : null;
  const imgUrl = fakeSlot ? getItemUrl(fakeSlot as any) : undefined;
  const rarityColor = data?.item ? getItemRarityColor(data.item, undefined) : undefined;

  const [{ isDragging }, drag] = useDrag<DragSource, void, { isDragging: boolean }>(
    () => ({
      type: 'WEAPON_SKIN_SLOT',
      canDrag: () => !!dataRef.current,
      item: () => {
        const current = dataRef.current;
        if (!current) return null;
        const url = getItemUrl({ name: current.item, slot: slotIndex } as any);
        return {
          inventory: 'weapon-skin' as any,
          item: { name: current.item, slot: slotIndex, count: 1 },
          image: url ? `url(${url})` : undefined,
        };
      },
      collect: (monitor) => ({ isDragging: monitor.isDragging() }),
    }),
    [slotIndex]
  );

  const [{ isOver, canDrop }, drop] = useDrop<DragSource, void, { isOver: boolean; canDrop: boolean }>(
    () => ({
      accept: ['SLOT', 'BACKPACK_SLOT', 'WEAPON_SKIN_SLOT'],
      canDrop: (source) => {
        if (source.inventory === 'weapon-skin') return source.item.slot !== slotIndex;
        if (dataRef.current) return false;
        return source.inventory === 'player' || source.inventory === 'backpack';
      },
      drop: (source) => {
        if (!source.item?.slot) return;
        setSuppressItemNotification(true);
        if (source.inventory === 'weapon-skin') {
          fetchNui('moveSkinSlot', { fromSlot: source.item.slot, toSlot: slotIndex });
        } else if (source.inventory === 'backpack') {
          fetchNui('equipWeaponSkinFromBackpack', { fromSlot: source.item.slot, toSlot: slotIndex });
        } else {
          fetchNui('equipWeaponSkin', { fromSlot: source.item.slot, toSlot: slotIndex });
        }
        setTimeout(() => setSuppressItemNotification(false), 1000);
      },
      collect: (monitor) => ({
        isOver: monitor.isOver(),
        canDrop: monitor.canDrop(),
      }),
    }),
    [slotIndex]
  );

  const connectRef = (el: HTMLDivElement) => drag(drop(el));

  return (
    <div
      ref={connectRef}
      className="inventory-slot"
      data-rarity={rarityColor ? '' : undefined}
      style={{
        ...(rarityColor ? ({ '--rarity-color': rarityColor } as React.CSSProperties) : {}),
        opacity: isDragging ? 0.4 : 1,
        border: isOver && canDrop ? '1px dashed rgba(255,255,255,0.4)' : '',
      }}
    >
      {data && imgUrl && (
        <div
          style={{
            position: 'absolute',
            inset: 0,
            backgroundImage: `url(${imgUrl})`,
            backgroundRepeat: 'no-repeat',
            backgroundPosition: 'center',
            backgroundSize: '68%',
            imageRendering: '-webkit-optimize-contrast',
            pointerEvents: 'none',
            zIndex: 0,
          }}
        />
      )}
      {data && (
        <div className="item-slot-wrapper">
          <div className="item-slot-header-wrapper" />
          <div>
            <div className="inventory-slot-label-box">
              <div className="inventory-slot-label-text">
                {Items[data.item]?.label || data.label || data.item}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

const WeaponSkinGrid: React.FC<WeaponSkinGridProps> = ({ skinSlots }) => {
  // Wrapper drop absorbs BACKPACK_SLOT drops that miss/hit occupied slots,
  // preventing BackpackSlot.end from firing backpackDropItem incorrectly.
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

  return (
    <div ref={gridDrop} className="inventory-grid-wrapper">
      <div className="inventory-grid-header-wrapper">
        <p>Skins Vũ Khí</p>
      </div>
      <div className="weapon-skin-grid-container">
        {Array.from({ length: TOTAL_SLOTS }, (_, i) => i + 1).map((i) => (
          <WeaponSkinSlot key={i} slotIndex={i} data={skinSlots[i]} />
        ))}
      </div>
    </div>
  );
};

export default WeaponSkinGrid;