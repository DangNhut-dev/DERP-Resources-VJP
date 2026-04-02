import React, { useContext, useRef } from 'react';
import { createPortal } from 'react-dom';
import { TransitionGroup } from 'react-transition-group';
import useNuiEvent from '../../hooks/useNuiEvent';
import useQueue from '../../hooks/useQueue';
import { Locale } from '../../store/locale';
import { getItemUrl } from '../../helpers';
import { SlotWithItem } from '../../typings';
import { Items } from '../../store/items';
import Fade from './transitions/Fade';
import { getItemRarityColor } from '../../store/rarity';

interface ItemNotificationProps {
  item: SlotWithItem;
  text: string;
}

// ── Suppress flag ─────────────────────────────────────────────
let suppressNotification = false;
export const setSuppressItemNotification = (val: boolean) => {
  suppressNotification = val;
};

export const ItemNotificationsContext = React.createContext<{
  add: (item: ItemNotificationProps) => void;
} | null>(null);

export const useItemNotifications = () => {
  const ctx = useContext(ItemNotificationsContext);
  if (!ctx) throw new Error(`ItemNotificationsContext undefined`);
  return ctx;
};

const ItemNotification = React.forwardRef(
  (props: { item: ItemNotificationProps; style?: React.CSSProperties }, ref: React.ForwardedRef<HTMLDivElement>) => {
    const slotItem = props.item.item;
    const rarityColor = getItemRarityColor(slotItem.name, slotItem.metadata);

    return (
      <div
        className="item-notification-item-box"
        data-rarity={rarityColor ? '' : undefined}
        style={{
          ...(rarityColor ? ({ '--rarity-color': rarityColor } as React.CSSProperties) : {}),
          ...props.style,
        }}
        ref={ref}
      >
        <div
          style={{
            position: 'absolute',
            inset: '0',
            backgroundImage: `url(${getItemUrl(slotItem) || 'none'})`,
            backgroundRepeat: 'no-repeat',
            backgroundPosition: 'center',
            backgroundSize: '68%',
            imageRendering: '-webkit-optimize-contrast',
            pointerEvents: 'none',
            zIndex: 0,
          } as React.CSSProperties}
        />
        <div className="item-slot-wrapper">
          <div className="item-notification-action-box">
            <p>{props.item.text}</p>
          </div>
          <div className="inventory-slot-label-box">
            <div className="inventory-slot-label-text">{slotItem.metadata?.label || Items[slotItem.name]?.label}</div>
          </div>
        </div>
      </div>
    );
  }
);

export const ItemNotificationsProvider = ({ children }: { children: React.ReactNode }) => {
  const queue = useQueue<{
    id: number;
    item: ItemNotificationProps;
    ref: React.RefObject<HTMLDivElement>;
  }>();

  const add = (item: ItemNotificationProps) => {
    if (suppressNotification) return;
    const ref = React.createRef<HTMLDivElement>();
    const notification = { id: Date.now(), item, ref };
    queue.add(notification);
    const timeout = setTimeout(() => {
      queue.remove();
      clearTimeout(timeout);
    }, 2500);
  };

  useNuiEvent<[item: SlotWithItem, text: string, count?: number]>('itemNotify', ([item, text, count]) => {
    if (suppressNotification) return;
    add({ item, text: count ? `${Locale[text]} ${count}x` : `${Locale[text]}` });
  });

  return (
    <ItemNotificationsContext.Provider value={{ add }}>
      {children}
      {createPortal(
        <TransitionGroup className="item-notification-container">
          {queue.values.map((notification, index) => (
            <Fade key={`item-notification-${index}`}>
              <ItemNotification item={notification.item} ref={notification.ref} />
            </Fade>
          ))}
        </TransitionGroup>,
        document.body
      )}
    </ItemNotificationsContext.Provider>
  );
};