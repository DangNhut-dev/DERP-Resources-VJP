// components/inventory/clothSlots.ts

export interface ClothSlotDef {
  slot: number;
  slotType: string;
  label: string;
  componentId: number;
  componentType: 'component' | 'props';
  itemName: string;
  icon: string;
  isGloveSelector?: boolean;
}

export interface ClothSlotData {
  name: string;
  drawableId: number;
  textureId: number;
  gender: number;
}

export interface GloveOption {
  drawable: number;
  texture: number;
}

export type ClothSlotsState = Record<number, ClothSlotData | null>;

export const CLOTH_SLOTS: ClothSlotDef[] = [
  { slot: 1,  slotType: 'hat',        label: 'Mũ',         componentId: 0,  componentType: 'props',     itemName: 'mu',        icon: 'hat.svg' },
  { slot: 2,  slotType: 'mask',       label: 'Mặt nạ',     componentId: 1,  componentType: 'component', itemName: 'matna',     icon: 'mask.svg' },
  { slot: 3,  slotType: 'jacket',     label: 'Áo khoác',   componentId: 11, componentType: 'component', itemName: 'aokhoac',   icon: 'jacket.svg' },
  { slot: 4,  slotType: 'undershirt', label: 'Áo trong',    componentId: 8,  componentType: 'component', itemName: 'aotrong',   icon: 'tshirt.svg' },
  { slot: 5,  slotType: 'gloves',     label: 'Găng tay',    componentId: 3,  componentType: 'component', itemName: 'tay',       icon: 'clothes.svg', isGloveSelector: true },
  { slot: 6,  slotType: 'pants',      label: 'Quần',        componentId: 4,  componentType: 'component', itemName: 'quan',      icon: 'pants.svg' },
  { slot: 7,  slotType: 'shoes',      label: 'Giày',        componentId: 6,  componentType: 'component', itemName: 'giay',      icon: 'shoes.svg' },
  { slot: 8,  slotType: 'glasses',    label: 'Kính',        componentId: 1,  componentType: 'props',     itemName: 'kinh',      icon: 'glasses.svg' },
  { slot: 9,  slotType: 'ear',        label: 'Khuyên tai',  componentId: 2,  componentType: 'props',     itemName: 'khuyentai', icon: 'earing.svg' },
  { slot: 10, slotType: 'necklace',   label: 'Dây chuyền',  componentId: 7,  componentType: 'component', itemName: 'daychuyen', icon: 'tie.svg' },
  { slot: 11, slotType: 'backpack',   label: 'Ba lô',       componentId: 5,  componentType: 'component', itemName: 'balo',      icon: 'backpack.svg' },
  { slot: 12, slotType: 'vest',       label: 'Giáp',        componentId: 9,  componentType: 'component', itemName: 'giap',      icon: 'bulletproof.svg' },
  { slot: 13, slotType: 'watch',      label: 'Đồng hồ',     componentId: 6,  componentType: 'props',     itemName: 'dongho',    icon: 'watch.svg' },
  { slot: 14, slotType: 'bracelet',   label: 'Vòng tay',    componentId: 7,  componentType: 'props',     itemName: 'vongtay',   icon: 'handcuff.svg' },
  { slot: 15, slotType: 'decal',      label: 'Huy Hiệu',    componentId: 10,  componentType: 'component',itemName: 'huyhieu',   icon: 'police.svg' },
];

import { clothesImagepath } from '../../store/imagepath';

export function getClothImageUrl(itemName: string, drawableId: number, textureId: number, gender: number): string {
  return `${clothesImagepath}/${itemName}_${drawableId}_${textureId}_${gender}.png`;
}