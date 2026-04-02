import { store } from '../store';
import { Slot, SlotWithItem } from '../typings';
import { selectLeftInventory } from '../store/inventory';

export const onGive = (item: Slot) => {
  if (!item.name) return;

  // DragSource.item chỉ có { name, slot, count }, thiếu weight/metadata
  // → lấy full SlotWithItem từ player inventory
  const leftInventory = selectLeftInventory(store.getState());
  const fullItem = leftInventory.items.find(
    (invItem) => invItem.slot === item.slot && invItem.name === item.name
  ) as SlotWithItem | undefined;

  if (!fullItem) return;

  window.dispatchEvent(
    new CustomEvent('ox_inventory:openGiveModal', {
      detail: { item: fullItem },
    })
  );
};