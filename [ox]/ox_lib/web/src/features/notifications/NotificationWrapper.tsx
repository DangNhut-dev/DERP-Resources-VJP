import { useNuiEvent } from '../../hooks/useNuiEvent';
import { toast, Toaster } from 'react-hot-toast';
import ReactMarkdown from 'react-markdown';
import { Box, Center, createStyles, keyframes, RingProgress, Stack, Text } from '@mantine/core';
import React, { useState } from 'react';
import type { NotificationProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';

const ACCENT = '#05F2F2';
const NOTIFICATION_WIDTH = 370;
const STRIP_WIDTH = 50;
const SKEW_PERCENT = 0.06;

const TYPE_COLORS: Record<string, string> = {
  error: '#ff3b30',
  success: '#32d74b',
  warning: '#ff9d0a',
  info: ACCENT,
};

const getTypeColor = (type?: string): string => TYPE_COLORS[type || 'info'] || ACCENT;

const useStyles = createStyles(() => ({
  outerWrapper: {
    position: 'relative',
    width: NOTIFICATION_WIDTH,
  },
  container: {
    width: NOTIFICATION_WIDTH,
    minHeight: 60,
    fontFamily: 'Roboto',
    clipPath: `polygon(${SKEW_PERCENT * 100}% 0%, 100% 0%, 100% 100%, 0% 100%)`,
    display: 'flex',
    flexDirection: 'row',
    overflow: 'hidden',
  },
  contentArea: {
    flex: 1,
    background: 'linear-gradient(to right, transparent, rgba(0, 0, 0, 0.85))',
    padding: '12px 24px 12px 28px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'flex-end',
  },
  typeStrip: {
    width: STRIP_WIDTH,
    minWidth: STRIP_WIDTH,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
  },
  title: {
    fontWeight: 600,
    fontSize: 15,
    lineHeight: 'normal',
    color: '#05F2F2',
  },
  description: {
    fontSize: 13,
    color: 'rgba(255, 255, 255, 0.7)',
    fontFamily: 'Roboto',
    lineHeight: 'normal',
  },
  descriptionOnly: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.7)',
    fontFamily: 'Roboto',
    lineHeight: 'normal',
  },
}));

const createAnimationFn = (from: string, to: string, visible: boolean) =>
  keyframes({
    from: { opacity: visible ? 0 : 1, transform: `translate${from}` },
    to: { opacity: visible ? 1 : 0, transform: `translate${to}` },
  });

const getAnimation = (visible: boolean, position: string) => {
  const animationOptions = visible ? '0.2s ease-out forwards' : '0.4s ease-in forwards';
  let animation: { from: string; to: string };

  if (visible) {
    animation = position.includes('bottom') ? { from: 'Y(30px)', to: 'Y(0px)' } : { from: 'Y(-30px)', to: 'Y(0px)' };
  } else {
    if (position.includes('right')) animation = { from: 'X(0px)', to: 'X(100%)' };
    else if (position.includes('left')) animation = { from: 'X(0px)', to: 'X(-100%)' };
    else if (position === 'top-center') animation = { from: 'Y(0px)', to: 'Y(-100%)' };
    else if (position === 'bottom') animation = { from: 'Y(0px)', to: 'Y(100%)' };
    else animation = { from: 'X(0px)', to: 'X(100%)' };
  }

  return `${createAnimationFn(animation.from, animation.to, visible)} ${animationOptions}`;
};

const durationCircle = keyframes({
  '0%': { strokeDasharray: `0, ${15.1 * 2 * Math.PI}` },
  '100%': { strokeDasharray: `${15.1 * 2 * Math.PI}, 0` },
});

// ===================== TÁCH RA NGOÀI =====================
interface ToastContentProps {
  data: NotificationProps;
  toastKey: number;
  duration: number;
  visible: boolean;
  position: string;
  typeColor: string;
  classes: Record<string, string>;
}

const ToastContent: React.FC<ToastContentProps> = ({ data, toastKey, duration, visible, position, typeColor, classes }) => {
  const containerRef = React.useRef<HTMLDivElement>(null);
  const [containerHeight, setContainerHeight] = React.useState(60);

  React.useEffect(() => {
    if (containerRef.current) {
      setContainerHeight(containerRef.current.offsetHeight);
    }
  }, [data.title, data.description]);

  return (
    <Box
      sx={{ animation: getAnimation(visible, position), ...data.style }}
      className={classes.outerWrapper}
    >
      <Box ref={containerRef} className={classes.container}>
        <Box className={classes.contentArea}>
          <Stack spacing={2} sx={{ textAlign: 'right' }}>
            {data.title && (
              <Text className={classes.title} sx={{ paddingRight: 24 }}>
                {data.title}
              </Text>
            )}
            {data.description && (
              <Box sx={{ paddingRight: 8 }}>
                <ReactMarkdown
                  components={MarkdownComponents}
                  className={`${!data.title ? classes.descriptionOnly : classes.description} description`}
                >
                  {data.description}
                </ReactMarkdown>
              </Box>
            )}
          </Stack>
        </Box>

        <Box
          className={classes.typeStrip}
          sx={{
            backgroundColor: typeColor,
            width: STRIP_WIDTH + NOTIFICATION_WIDTH * SKEW_PERCENT,
            minWidth: STRIP_WIDTH + NOTIFICATION_WIDTH * SKEW_PERCENT,
            marginLeft: -(NOTIFICATION_WIDTH * SKEW_PERCENT),
            clipPath: `polygon(${(NOTIFICATION_WIDTH * SKEW_PERCENT) / (STRIP_WIDTH + NOTIFICATION_WIDTH * SKEW_PERCENT) * 100}% 0%, 100% 0%, 100% 100%, 0% 100%)`,
            paddingLeft: NOTIFICATION_WIDTH * SKEW_PERCENT,
          }}
        >
          {data.icon && (
            <>
              {data.showDuration ? (
                <RingProgress
                  key={toastKey}
                  size={38}
                  thickness={2}
                  sections={[{ value: 100, color: 'rgba(255, 255, 255, 0.6)' }]}
                  styles={{
                    root: {
                      '> svg > circle:nth-of-type(1)': { stroke: 'rgba(255, 255, 255, 0.2)' },
                      '> svg > circle:nth-of-type(2)': {
                        animation: `${durationCircle} linear forwards reverse`,
                        animationDuration: `${duration}ms`,
                      },
                      margin: -2,
                    },
                  }}
                  label={
                    <Center>
                      <LibIcon icon={data.icon} fixedWidth color="#000000" animation={data.iconAnimation} fontSize={24} />
                    </Center>
                  }
                />
              ) : (
                <LibIcon icon={data.icon} fixedWidth color="#000000" animation={data.iconAnimation} fontSize={24} />
              )}
            </>
          )}
        </Box>
      </Box>
    </Box>
  );
};
// ===================== HẾT TÁCH =====================

const Notifications: React.FC = () => {
  const { classes } = useStyles();
  const [toastKey, setToastKey] = useState(0);

  useNuiEvent<NotificationProps>('notify', (data) => {
    if (!data.title && !data.description) return;

    const toastId = data.id?.toString();
    const duration = data.duration || 3000;
    let position = data.position || 'top-right';

    data.showDuration = data.showDuration !== undefined ? data.showDuration : true;

    if (toastId) setToastKey((prev) => prev + 1);

    switch (position) {
      case 'top': position = 'top-center'; break;
      case 'bottom': position = 'bottom-center'; break;
      // case 'center-right': position = 'top-right'; break;
      // case 'center-left': position = 'top-left'; break;
    }

    if (!data.icon) {
      switch (data.type) {
        case 'error': data.icon = 'circle-xmark'; break;
        case 'success': data.icon = 'circle-check'; break;
        case 'warning': data.icon = 'circle-exclamation'; break;
        default: data.icon = 'circle-info'; break;
      }
    }

    const typeColor = data.iconColor || getTypeColor(data.type);
    const currentKey = toastKey;

    toast.custom(
      (t) => (
        <ToastContent
          data={data}
          toastKey={currentKey}
          duration={duration}
          visible={t.visible}
          position={position}
          typeColor={typeColor}
          classes={classes}
        />
      ),
      { id: toastId, duration: duration }
    );
  });

  return (
    <Toaster
      position="top-right"
      containerStyle={{
        top: '50%',
        right: 20,
        transform: 'translateY(-50%)',
        position: 'fixed',
      }}
      toastOptions={{
        style: { maxWidth: NOTIFICATION_WIDTH },
      }}
    />
  );
};

export default Notifications;