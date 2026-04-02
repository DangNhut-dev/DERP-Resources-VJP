// components/inventory/BackpackGrid.tsx
// @ts-nocheck
import React, { useMemo, useRef, useCallback } from 'react';
import { BackpackData, BackpackItem } from './backpack';
import { DragSource, SlotWithItem } from '../../typings';
import { useDrag, useDrop } from 'react-dnd';
import { useAppDispatch } from '../../store';
import { useStore } from 'react-redux';
import { closeTooltip, openTooltip } from '../../store/tooltip';
import { selectItemAmount } from '../../store/inventory';
import { Items } from '../../store/items';
import { fetchNui } from '../../utils/fetchNui';
import { getItemUrl } from '../../helpers';
import WeightBar from '../utils/WeightBar';
import { getItemRarityColor } from '../../store/rarity';

function parseBackpackItems(rawItems: any, totalSlots: number): Record<number, BackpackItem | null> {
  const result: Record<number, BackpackItem | null> = {};
  if (!rawItems) return result;
  for (const key of Object.keys(rawItems)) {
    const slotNum = parseInt(key.replace('s', ''), 10);
    if (!isNaN(slotNum) && slotNum >= 1 && slotNum <= totalSlots) {
      result[slotNum] = rawItems[key];
    }
  }
  return result;
}

interface BackpackSlotProps {
  item: BackpackItem | null;
  slotIndex: number;
}

const BackpackSlot: React.FC<BackpackSlotProps> = React.memo(({ item, slotIndex }) => {
  const dispatch = useAppDispatch();
  const store = useStore();
  const hasItem = !!item;
  const timerRef = useRef<number | null>(null);
  const itemRef = useRef(item);
  itemRef.current = item;

  const [{ isDragging }, drag] = useDrag<DragSource, void, { isDragging: boolean }>(
    () => ({
      type: 'BACKPACK_SLOT',
      collect: (monitor) => ({ isDragging: monitor.isDragging() }),
      item: () => {
        const currentItem = itemRef.current;
        if (!currentItem) return null;
        return {
          inventory: 'backpack' as any,
          item: {
            name: currentItem.name,
            slot: slotIndex,
            count: currentItem.count,
          },
          image: currentItem.name ? `url(${getItemUrl(currentItem as any) || 'none'})` : 'none',
        };
      },
      canDrag: () => hasItem,
    }),
    [hasItem, slotIndex]
  );

  const [{ isOver }, drop] = useDrop<DragSource, void, { isOver: boolean }>(
    () => ({
      accept: ['SLOT', 'BACKPACK_SLOT', 'CLOTH_SLOT', 'WEAPON_SKIN_SLOT'],
      collect: (monitor) => ({ isOver: monitor.isOver() }),
      drop: (source) => {
        dispatch(closeTooltip());
        const amount = selectItemAmount(store.getState());
        const sourceCount = (source.item as any).count || 1;
        const count = amount > 0 ? amount : sourceCount;

        if ((source.inventory as string) === 'weapon-skin') {
          fetchNui('unequipWeaponSkinToBackpack', {
            skinSlot: source.item.slot,
            toSlot: slotIndex,
          });
          return;
        }

        if (source.inventory === 'cloth-slot') {
          fetchNui('clothSlotUnequipToBackpack', {
            clothSlot: source.item.slot,
            toSlot: slotIndex,
          });
          return;
        }

        if (source.inventory === 'backpack') {
          if (source.item.slot === slotIndex) return;
          fetchNui('backpackSwap', {
            fromSlot: source.item.slot,
            toSlot: slotIndex,
            fromType: 'backpack',
            toType: 'backpack',
            count,
          });
        } else if (source.inventory === 'player') {
          fetchNui('backpackSwap', {
            fromSlot: source.item.slot,
            toSlot: slotIndex,
            fromType: 'player',
            toType: 'backpack',
            count,
          });
        } else {
          fetchNui('backpackSwap', {
            fromSlot: source.item.slot,
            toSlot: slotIndex,
            fromType: 'right',
            toType: 'backpack',
            count,
          });
        }
      },
      canDrop: (source) => {
        if ((source.inventory as string) === 'shop' || (source.inventory as string) === 'crafting') return false;
        if ((source.inventory as string) === 'weapon-skin') return !hasItem;
        if (source.inventory === ('cloth-slot' as any)) return source.item?.name !== 'balo';
        if (source.item?.name === 'balo') return false;
        return true;
      },
    }),
    [slotIndex, dispatch, store, hasItem]
  );

  const ref = useCallback(
    (node: HTMLDivElement | null) => {
      drag(drop(node));
    },
    [drag, drop]
  );

  const rarityColor = hasItem && item.name ? getItemRarityColor(item.name, item.metadata) : undefined;

  return (
    <div
      ref={ref}
      className="inventory-slot"
      data-slot={slotIndex}
      data-rarity={rarityColor ? '' : undefined}
      style={{
        ...(rarityColor ? ({ '--rarity-color': rarityColor } as React.CSSProperties) : {}),
        opacity: isDragging ? 0.4 : 1,
        border: isOver ? '1px dashed rgba(255,255,255,0.4)' : '',
      }}
    >
      {hasItem && item.name && (
        <div
          style={{
            position: 'absolute',
            inset: '0',
            backgroundImage: `url(${getItemUrl(item as any) || 'none'})`,
            backgroundRepeat: 'no-repeat',
            backgroundPosition: 'center',
            backgroundSize: '68%',
            imageRendering: '-webkit-optimize-contrast',
            pointerEvents: 'none',
            zIndex: 0,
          } as React.CSSProperties}
        />
      )}
      {hasItem && (
        <div
          className="item-slot-wrapper"
          onMouseEnter={() => {
            timerRef.current = window.setTimeout(() => {
              dispatch(openTooltip({ item: item as any, inventoryType: 'backpack' as any }));
            }, 500) as unknown as number;
          }}
          onMouseLeave={() => {
            dispatch(closeTooltip());
            if (timerRef.current) {
              clearTimeout(timerRef.current);
              timerRef.current = null;
            }
          }}
        >
          <div className="item-slot-header-wrapper">
            <div className="item-slot-info-wrapper">
              <p>
                {item.weight > 0
                  ? item.weight >= 1000
                    ? `${(item.weight / 1000).toLocaleString('en-us', { minimumFractionDigits: 2 })}kg `
                    : `${item.weight.toLocaleString('en-us', { minimumFractionDigits: 0 })}g `
                  : ''}
              </p>
              <p>{item.count ? item.count.toLocaleString('en-us') + 'x' : ''}</p>
            </div>
          </div>
          <div>
            <div className="inventory-slot-label-box">
              <div className="inventory-slot-label-text">
                {item.metadata?.label || Items[item.name]?.label || item.name}
              </div>
            </div>
            {(item.durability !== undefined || item.metadata?.durability !== undefined) && (
              <WeightBar percent={item.durability ?? item.metadata?.durability ?? 0} durability />
            )}
          </div>
        </div>
      )}
    </div>
  );
});

interface BackpackGridProps {
  backpack: BackpackData;
}

const GRID_COLS = 5;
const MAX_VISIBLE_ROWS = 4;

const BackpackGrid: React.FC<BackpackGridProps> = ({ backpack }) => {
  const parsedItems = useMemo(() => {
    return parseBackpackItems(backpack.items, backpack.slots);
  }, [backpack.items, backpack.slots]);

  const slots = useMemo(() => {
    const arr: (BackpackItem | null)[] = [];
    for (let i = 1; i <= backpack.slots; i++) {
      arr.push(parsedItems[i] || null);
    }
    return arr;
  }, [parsedItems, backpack.slots]);

  const weightPercent = backpack.maxWeight > 0 ? (backpack.weight / backpack.maxWeight) * 100 : 0;
  const weightKg = (backpack.weight / 1000).toFixed(2);
  const maxWeightKg = (backpack.maxWeight / 1000).toFixed(2);

  const maxVisibleSlots = GRID_COLS * MAX_VISIBLE_ROWS;
  const needsScroll = backpack.slots > maxVisibleSlots;

  return (
    <div className="inventory-grid-wrapper">
      <div>
        <div className="inventory-grid-header-wrapper">
          <p>{backpack.label} <span className="backpack-level-badge">Lv.{backpack.level}</span></p>
          <p>{weightKg}/{maxWeightKg}kg</p>
        </div>
        <WeightBar percent={weightPercent} />
      </div>
      <div
        className="inventory-grid-container backpack-grid-scroll"
        style={{
          maxHeight: needsScroll ? `calc(${MAX_VISIBLE_ROWS} * 10.2vh + ${MAX_VISIBLE_ROWS - 1} * 3px)` : undefined,
          overflowY: needsScroll ? 'auto' : 'hidden',
        }}
      >
        {slots.map((item, index) => (
          <BackpackSlot
            key={`bp-${index + 1}`}
            item={item}
            slotIndex={index + 1}
          />
        ))}
      </div>
    </div>
  );
};

export default BackpackGrid;