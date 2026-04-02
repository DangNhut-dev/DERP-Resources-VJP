// components/inventory/Inventory.tsx (UPDATED)
// @ts-nocheck
import React, { useState, useEffect, useRef } from 'react';
import useNuiEvent from '../../hooks/useNuiEvent';
import InventoryControl from './InventoryControl';
import InventoryHotbar from './InventoryHotbar';
import { useAppDispatch } from '../../store';
import { refreshSlots, setAdditionalMetadata, setupInventory } from '../../store/inventory';
import { useExitListener } from '../../hooks/useExitListener';
import type { Inventory as InventoryProps } from '../../typings';
import RightInventory from './RightInventory';
import LeftInventory from './LeftInventory';
import ClothSlotGrid from './ClothSlotGrid';
import BackpackGrid from './BackpackGrid';
import WeaponSkinGrid, { WeaponSkinSlotData, WeaponSkinSlotsState } from './WeaponSkinGrid';
import Tooltip from '../utils/Tooltip';
import { closeTooltip } from '../../store/tooltip';
import { closeContextMenu } from '../../store/contextMenu';
import InventoryContext from './InventoryContext';
import Fade from '../utils/transitions/Fade';
import { ClothSlotData, ClothSlotsState, GloveOption } from './clothSlots';
import { BackpackData } from './backpack';
import { fetchNui } from '../../utils/fetchNui';
import GiveModal from './GiveModal';
import { SlotWithItem } from '../../typings';
import { InventoryTab } from './InventoryGrid';

export type RightPanelMode = 'inventory' | 'cloth-slot' | 'weapon-skin';

const Inventory: React.FC = () => {
  const [inventoryVisible, setInventoryVisible] = useState(false);
  const [rightPanel, setRightPanel] = useState<RightPanelMode>('inventory');
  const [panelVisible, setPanelVisible] = useState(true);
  const [clothSlots, setClothSlots] = useState<ClothSlotsState>({});
  const [gloveOptions, setGloveOptions] = useState<GloveOption[]>([]);
  const [backpackData, setBackpackData] = useState<BackpackData | null>(null);
  const [giveItem, setGiveItem] = useState<SlotWithItem | null>(null);
  const [isFreemode, setIsFreemode] = useState(true);
  const [activeTab, setActiveTab] = useState<InventoryTab>('drop');
  const [hasDecalAccess, setHasDecalAccess] = useState(false);
  const [weaponSkinSlots, setWeaponSkinSlots] = useState<WeaponSkinSlotsState>({});
  const dispatch = useAppDispatch();

  // ── Tab handler — sync rightPanel + persist tab ────────────
  const handleTabChange = (tab: InventoryTab) => {
    if (tab === activeTab) return;
    setActiveTab(tab);

    if (tab === 'drop') {
      switchPanel('inventory');
    } else if (tab === 'cloth-slot') {
      switchPanel('cloth-slot');
    } else if (tab === 'weapon-skin') {
      switchPanel('weapon-skin');
    }
  };

  // ── Listen GiveModal custom event from onGive.ts ───────────
  useEffect(() => {
    const handler = (e: Event) => {
      const detail = (e as CustomEvent).detail;
      if (detail?.item) setGiveItem(detail.item);
    };
    window.addEventListener('ox_inventory:openGiveModal', handler);
    return () => window.removeEventListener('ox_inventory:openGiveModal', handler);
  }, []);

  // ── Cloth Slots Sync ───────────────────────────────────────
  useNuiEvent('syncClothSlots', (data: any) => {
    if (!data) { setClothSlots({}); return; }

    const rawSlots = data.clothSlots || data;
    const parsed: ClothSlotsState = {};

    if (Array.isArray(rawSlots)) {
      rawSlots.forEach((item: ClothSlotData | null, index: number) => {
        if (item) parsed[index + 1] = item;
      });
    } else {
      for (const [key, value] of Object.entries(rawSlots)) {
        if (value) parsed[Number(key)] = value as ClothSlotData;
      }
    }

    setClothSlots(parsed);

    if (data.gloveOptions && (data.gloveOptions as GloveOption[]).length > 0) {
      setGloveOptions(data.gloveOptions);
    }

    if (data.isFreemode !== undefined) {
      setIsFreemode(data.isFreemode);
    }

    if (data.hasDecalAccess !== undefined) {
      setHasDecalAccess(data.hasDecalAccess);
    }
  });

  // ── Weapon Skin Slots Sync ─────────────────────────────────
  useNuiEvent('syncWeaponSkinSlots', (data: any) => {
    if (!data) { setWeaponSkinSlots({}); return; }

    const parsed: WeaponSkinSlotsState = {};
    for (const [key, value] of Object.entries(data)) {
      if (value) parsed[Number(key)] = value as WeaponSkinSlotData;
    }
    setWeaponSkinSlots(parsed);
  });

  // ── Backpack Sync ──────────────────────────────────────────
  useNuiEvent('backpackData', (data: BackpackData | null) => {
    setBackpackData(data);
  });

  useNuiEvent('backpackUpdate', (data: any) => {
    if (!data || !backpackData) return;
    setBackpackData((prev) => {
      if (!prev) return null;
      return {
        ...prev,
        weight: data.weight,
        items: data.items || prev.items,
      };
    });
  });

  // ── Panel Switching ────────────────────────────────────────
  const switchPanel = (mode: RightPanelMode) => {
    if (rightPanel === mode) return;
    setPanelVisible(false);
    setTimeout(() => {
      setRightPanel(mode);
      setPanelVisible(true);
    }, 200);
  };

  useNuiEvent<boolean>('setInventoryVisible', setInventoryVisible);
  useNuiEvent<false>('closeInventory', () => {
    setInventoryVisible(false);
    setPanelVisible(true);
    setGiveItem(null);
    dispatch(closeContextMenu());
  });

  useExitListener(setInventoryVisible);

  useNuiEvent<{
    leftInventory: InventoryProps;
    rightInventory?: InventoryProps;
  }>('setupInventory', (data) => {
    dispatch(setupInventory(data));
    setPanelVisible(true);
    !inventoryVisible && setInventoryVisible(true);
  });

  useNuiEvent('refreshSlots', (data) => dispatch(refreshSlots(data)));
  useNuiEvent('setAdditionalMetadata', (data: Array<{ metadata: string; value: string }>) =>
    dispatch(setAdditionalMetadata(data))
  );
  useNuiEvent('displayMetadata', (data: Array<{ metadata: string; value: string }>) =>
    dispatch(setAdditionalMetadata(data))
  );

  useNuiEvent('showClothSlot', () => {
    setActiveTab('cloth-slot');
    switchPanel('cloth-slot');
    fetchNui('requestClothSync');
  });
  useNuiEvent('showDropInventory', () => {
    setActiveTab('drop');
    switchPanel('inventory');
  });
  useNuiEvent('showWeaponSkin', () => {
    setActiveTab('weapon-skin');
    switchPanel('weapon-skin');
    fetchNui('requestWeaponSkinSync');
  });

  return (
    <>
      <Fade in={inventoryVisible}>
        <div className="inventory-wrapper">
          {/* ── Left side: Player inventory + Backpack ── */}
          <div className="left-panel-wrapper">
            <LeftInventory activeTab={activeTab} onTabChange={handleTabChange} />
            {backpackData && <BackpackGrid backpack={backpackData} />}
          </div>

          <InventoryControl />

          {/* ── Right side: Inventory / Cloth Slots / Weapon Skins ── */}
          <div
            className="right-panel-wrapper"
            style={{
              opacity: panelVisible ? 1 : 0,
              transition: 'opacity 200ms ease',
            }}
          >
            {rightPanel === 'inventory' ? (
              <RightInventory />
            ) : rightPanel === 'cloth-slot' ? (
              <ClothSlotGrid clothSlots={clothSlots} gloveOptions={gloveOptions} isFreemode={isFreemode} hasDecalAccess={hasDecalAccess} />
            ) : (
              <WeaponSkinGrid skinSlots={weaponSkinSlots} />
            )}
          </div>
          <Tooltip />
          <InventoryContext />
          {giveItem && (
            <GiveModal
              item={giveItem}
              onClose={() => setGiveItem(null)}
            />
          )}
        </div>
      </Fade>
      <InventoryHotbar />
    </>
  );
};

export default Inventory;