// store/rarity.ts

export interface RarityTier {
  color: string;
  order: number;
  label: string;
}

export interface RarityData {
  tiers: Record<string, RarityTier>;
  items: Record<string, string>;
  clothing: Record<string, string>;
}

const rarityData: RarityData = {
  tiers: {},
  items: {},
  clothing: {},
};

export function setRarityData(data: RarityData) {
  if (!data) return;
  rarityData.tiers = data.tiers || {};
  rarityData.items = data.items || {};
  rarityData.clothing = data.clothing || {};
}

/** Trả về color hex nếu item có rarity, undefined nếu không */
export function getItemRarityColor(
  itemName?: string,
  metadata?: Record<string, any>
): string | undefined {
  if (!itemName) return undefined;

  let tier: string | undefined;

  // Clothing: build full key từ metadata
  if (
    metadata &&
    metadata.drawableId !== undefined &&
    metadata.textureId !== undefined &&
    metadata.gender !== undefined
  ) {
    const key = `${itemName}_${metadata.drawableId}_${metadata.textureId}_${metadata.gender}`;
    tier = rarityData.clothing[key];
  }

  // Fallback: item thường
  if (!tier) {
    tier = rarityData.items[itemName];
  }

  if (!tier) return undefined;
  return rarityData.tiers[tier]?.color;
}