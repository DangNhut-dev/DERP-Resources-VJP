import React from 'react';
import { Box, createStyles, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import type { ProgressbarProps } from '../../typings';

const useStyles = createStyles((theme) => ({
  wrapper: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    bottom: 55,
    position: 'absolute',
  },
  innerWrapper: {
    position: 'relative',
    width: 350,
    height: 45,
  },
  container: {
    width: 350,
    height: 45,
    backgroundColor: 'rgba(0, 0, 0, 0.85)',
    overflow: 'hidden',
    clipPath: 'polygon(8% 0%, 100% 0%, 92% 100%, 0% 100%)',
  },
  bar: {
    height: '100%',
    background: 'linear-gradient(90deg, rgba(5, 242, 242, 0.3), #05F2F2)',
  },
  labelWrapper: {
    position: 'absolute',
    display: 'flex',
    width: 350,
    height: 45,
    alignItems: 'center',
    justifyContent: 'center',
  },
  label: {
    maxWidth: 350,
    padding: 8,
    textOverflow: 'ellipsis',
    overflow: 'hidden',
    whiteSpace: 'nowrap',
    fontSize: 20,
    color: '#FFFFFF',
    textShadow: '0 1px 3px rgba(0, 0, 0, 0.5)',
  },
  borderOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: 350,
    height: 45,
    pointerEvents: 'none',
    zIndex: 1,
  },
}));

const Progressbar: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);

  useNuiEvent('progressCancel', () => setVisible(false));

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
  });

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible} onExitComplete={() => fetchNui('progressComplete')}>
          <Box className={classes.innerWrapper}>
            {/* SVG border cho hình thang */}
            <Box className={classes.borderOverlay}>
              <svg
                width="350"
                height="45"
                viewBox="0 0 350 45"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <polygon
                  points="28,1 349,1 322,44 1,44"
                  fill="none"
                  stroke="rgba(255, 255, 255, 0.35)"
                  strokeWidth="1.5"
                  strokeLinejoin="miter"
                />
              </svg>
            </Box>
            {/* Progress container với clip-path hình thang */}
            <Box className={classes.container}>
              <Box
                className={classes.bar}
                onAnimationEnd={() => setVisible(false)}
                sx={{
                  animation: 'progress-bar linear',
                  animationDuration: `${duration}ms`,
                }}
              >
                <Box className={classes.labelWrapper}>
                  <Text className={classes.label}>{label}</Text>
                </Box>
              </Box>
            </Box>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default Progressbar;