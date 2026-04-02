import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Inventory } from '../../typings';
import WeightBar from '../utils/WeightBar';
import InventorySlot from './InventorySlot';
import { getTotalWeight } from '../../helpers';
import { useAppSelector } from '../../store';
import { useIntersection } from '../../hooks/useIntersection';

const sendNui = (event: string) => {
  fetch(`https://ox_inventory/${event}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  }).catch(() => {});
};

const PAGE_SIZE = 30;

export type InventoryTab = 'drop' | 'cloth-slot' | 'weapon-skin';

interface InventoryGridProps {
  inventory: Inventory;
  activeTab?: InventoryTab;
  onTabChange?: (tab: InventoryTab) => void;
}

const InventoryGrid: React.FC<InventoryGridProps> = ({ inventory, activeTab, onTabChange }) => {
  const weight = useMemo(
    () => (inventory.maxWeight !== undefined ? Math.floor(getTotalWeight(inventory.items) * 1000) / 1000 : 0),
    [inventory.maxWeight, inventory.items]
  );
  const [page, setPage] = useState(0);
  const containerRef = useRef(null);
  const { ref, entry } = useIntersection({ threshold: 0.5 });
  const isBusy = useAppSelector((state) => state.inventory.isBusy);

  useEffect(() => {
    if (entry && entry.isIntersecting) {
      setPage((prev) => ++prev);
    }
  }, [entry]);

  const isPlayer = inventory.type === 'player';

  const handleTab = (tab: InventoryTab) => {
    if (onTabChange) onTabChange(tab);
    sendNui(tab);
  };

  return (
    <>
      <div className="inventory-grid-wrapper" style={{ pointerEvents: isBusy ? 'none' : 'auto' }}>
        <div>
          {/* Row 1: Label + Tabs */}
          <div className="inventory-grid-header-wrapper">
            <p>{inventory.label}</p>
            {isPlayer && (
              <div className="inventory-header-tabs">
                <button
                  className={`inventory-header-tab${activeTab === 'drop' ? ' inventory-header-tab--active' : ''}`}
                  onClick={() => handleTab('drop')}
                >
                  <img src="assets/icons/svg/item.svg" alt="drop" />
                </button>
                <button
                  className={`inventory-header-tab${activeTab === 'cloth-slot' ? ' inventory-header-tab--active' : ''}`}
                  onClick={() => handleTab('cloth-slot')}
                >
                  <img src="assets/icons/svg/clothes.svg" alt="cloth-slot" />
                </button>
                <button
                  className={`inventory-header-tab${activeTab === 'weapon-skin' ? ' inventory-header-tab--active' : ''}`}
                  onClick={() => handleTab('weapon-skin')}
                >
                  <img src="assets/icons/svg/scope.svg" alt="weapon-skin" />
                </button>
              </div>
            )}
          </div>

          {/* Row 2: WeightBar + Weight text */}
          {inventory.maxWeight && (
            <div className="inventory-grid-weight-row">
              <div className="inventory-grid-weight-bar">
                <WeightBar percent={(weight / inventory.maxWeight) * 100} />
              </div>
              <p className="inventory-grid-weight-text">
                {weight / 1000}/{inventory.maxWeight / 1000}kg
              </p>
            </div>
          )}
        </div>
        <div className="inventory-grid-container" ref={containerRef}>
          {inventory.items.slice(0, (page + 1) * PAGE_SIZE).map((item, index) => (
            <InventorySlot
              key={`${inventory.type}-${inventory.id}-${item.slot}`}
              item={item}
              ref={index === (page + 1) * PAGE_SIZE - 1 ? ref : null}
              inventoryType={inventory.type}
              inventoryGroups={inventory.groups}
              inventoryId={inventory.id}
            />
          ))}
        </div>
      </div>
    </>
  );
};

export default InventoryGrid;