import { Box, createStyles } from '@mantine/core';
import { useEffect, useState, useCallback, useRef } from 'react';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { fetchNui } from '../../../utils/fetchNui';
import { isIconUrl } from '../../../utils/isIconUrl';
import type { RadialMenuItem } from '../../../typings';
import LibIcon from '../../../components/LibIcon';

const HEX_W = 5.2;
const HEX_H = 2.86;
const TRI_H = 1.3;
const GAP = 0.52;
const FONT_ICON = '1.56vw';
const FONT_LABEL = '0.68vw';

interface HexPos {
  top: number;
  left: number;
}

const FULL_HEX_H = HEX_H + TRI_H * 2;
const ROW_OFFSET = FULL_HEX_H * 0.75 + GAP;

const hexPositions: HexPos[] = [
  { top: 0, left: 0 },
  { top: 0, left: HEX_W + GAP },
  { top: 0, left: (HEX_W + GAP) * 2 },
  { top: ROW_OFFSET, left: (HEX_W + GAP) * 0.5 },
  { top: ROW_OFFSET, left: (HEX_W + GAP) * 1.5 },
  { top: ROW_OFFSET, left: (HEX_W + GAP) * 2.5 },
];

const useStyles = createStyles(() => ({
  wrapper: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    pointerEvents: 'none',
  },
  container: {
    position: 'relative',
    pointerEvents: 'auto',
    transformOrigin: 'center center',
  },
  hexOuter: {
    position: 'absolute',
    width: `${HEX_W}vw`,
    height: `${FULL_HEX_H}vw`,
    background: 'rgba(255, 255, 255, 0.35)',
    clipPath: 'polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%)',
    cursor: 'pointer',
    zIndex: 1,
    transition: 'transform 0.2s, background 0.2s',

    '&:hover': {
      transform: 'scale(1.08)',
      background: '#05f2f2b3',
    },
  },
  hexInner: {
    position: 'absolute',
    top: '2px',
    left: '2px',
    right: '2px',
    bottom: '2px',
    background: 'rgba(24, 24, 24, 0.85)',
    clipPath: 'polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    pointerEvents: 'none',
  },
  iconWrapper: {
    pointerEvents: 'none',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: '0.2vw',
  },
  iconImage: {
    width: FONT_ICON,
    height: FONT_ICON,
    objectFit: 'contain' as const,
  },
  label: {
    pointerEvents: 'none',
    color: '#FFFFFF',
    fontSize: FONT_LABEL,
    textAlign: 'center' as const,
    lineHeight: 1.3,
    maxWidth: '90%',
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap' as const,
    fontFamily: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif`,
  },
}));

const PAGE_ITEMS = 6;

const RadialMenu: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const [menuItems, setMenuItems] = useState<RadialMenuItem[]>([]);
  const [animKey, setAnimKey] = useState(0);
  const subRef = useRef(false);

  const closeMenu = useCallback(() => {
    setVisible(false);
    subRef.current = false;
    fetchNui('radialClose');
  }, []);

  const goBack = useCallback(() => {
    if (subRef.current) {
      fetchNui('radialBack');
    } else {
      closeMenu();
    }
  }, [closeMenu]);

  useNuiEvent('openRadialMenu', (data: { items: RadialMenuItem[]; sub?: boolean; option?: string } | false) => {
    if (!data) {
      setVisible(false);
      return;
    }
    subRef.current = !!data.sub;
    setMenuItems(data.items.slice(0, PAGE_ITEMS));
    setAnimKey((k) => k + 1);
    setVisible(true);
  });

  useNuiEvent('refreshItems', (data: RadialMenuItem[]) => {
    setMenuItems(data.slice(0, PAGE_ITEMS));
  });

  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && visible) {
        closeMenu();
      }
    };
    window.addEventListener('keydown', handleKey);
    return () => window.removeEventListener('keydown', handleKey);
  }, [visible, closeMenu]);

  useEffect(() => {
    const handleContext = (e: MouseEvent) => {
      if (visible) {
        e.preventDefault();
        goBack();
      }
    };
    window.addEventListener('contextmenu', handleContext);
    return () => window.removeEventListener('contextmenu', handleContext);
  }, [visible, goBack]);

  if (!visible) return null;

  return (
    <Box className={classes.wrapper}>
      <style>{`
        @keyframes hexShow {
          0% { transform: scale(0); opacity: 0; }
          100% { transform: scale(1.2); opacity: 1; }
        }
      `}</style>
      <div
        key={animKey}
        className={classes.container}
        style={{
          width: `${(HEX_W + GAP) * 3 + HEX_W * 0.5}vw`,
          height: `${ROW_OFFSET + FULL_HEX_H}vw`,
          animation: 'hexShow 0.5s forwards',
        }}
      >
        {menuItems.map((item, index) => {
          if (index >= PAGE_ITEMS) return null;
          const pos = hexPositions[index];
          return (
            <div
              key={`${item.label}-${index}`}
              className={classes.hexOuter}
              style={{ top: `${pos.top}vw`, left: `${pos.left}vw` }}
              onClick={() => {
                fetchNui('radialClick', index);
              }}
            >
              <div className={classes.hexInner}>
                <div className={classes.iconWrapper}>
                  {typeof item.icon === 'string' && isIconUrl(item.icon) ? (
                    <img src={item.icon} className={classes.iconImage} alt="" />
                  ) : (
                    <LibIcon
                      icon={item.icon as IconProp}
                      fixedWidth
                      color="#05f2f2b3"
                      fontSize={FONT_ICON}
                    />
                  )}
                </div>
                <div className={classes.label}>{item.label}</div>
              </div>
            </div>
          );
        })}
      </div>
    </Box>
  );
};

export default RadialMenu;