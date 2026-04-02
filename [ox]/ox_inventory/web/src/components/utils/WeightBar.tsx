import React, { useMemo } from 'react';

const colorChannelMixer = (colorChannelA: number, colorChannelB: number, amountToMix: number) => {
  let channelA = colorChannelA * amountToMix;
  let channelB = colorChannelB * (1 - amountToMix);
  return channelA + channelB;
};

const colorMixer = (rgbA: number[], rgbB: number[], amountToMix: number) => {
  let r = colorChannelMixer(rgbA[0], rgbB[0], amountToMix);
  let g = colorChannelMixer(rgbA[1], rgbB[1], amountToMix);
  let b = colorChannelMixer(rgbA[2], rgbB[2], amountToMix);
  return `rgb(${r}, ${g}, ${b})`;
};

const COLORS = {
  primaryColor: [231, 76, 60],
  secondColor: [39, 174, 96],
  accentColor: [211, 84, 0],
};

const BRICK_COUNT = 20;
const BRICK_WIDTH = 8;
const BRICK_GAP = 2;
const BRICK_HEIGHT = 6;
const SKEW = -20;

const WeightBricks: React.FC<{ percent: number }> = ({ percent }) => {
  const filledCount = Math.round((percent / 100) * BRICK_COUNT);

  return (
    <div
      style={{
        display: 'flex',
        gap: `${BRICK_GAP}px`,
        alignItems: 'center',
        height: `${BRICK_HEIGHT}px`,
        flex: 1,
        minWidth: 0,
      }}
    >
      {Array.from({ length: BRICK_COUNT }, (_, i) => {
        const isFilled = i < filledCount;
        return (
          <div
            key={i}
            style={{
              flex: 1,
              height: '100%',
              transform: `skewX(${SKEW}deg)`,
              backgroundColor: isFilled ? '#05F2F2' : 'transparent',
              border: isFilled ? 'none' : '1px solid rgba(255,255,255,0.12)',
              transition: 'background-color 0.3s ease',
            }}
          />
        );
      })}
    </div>
  );
};

const WeightBar: React.FC<{ percent: number; durability?: boolean }> = ({ percent, durability }) => {
  const color = useMemo(
    () =>
      durability
        ? percent < 50
          ? colorMixer(COLORS.accentColor, COLORS.primaryColor, percent / 100)
          : colorMixer(COLORS.secondColor, COLORS.accentColor, percent / 100)
        : percent > 50
        ? colorMixer(COLORS.primaryColor, COLORS.accentColor, percent / 100)
        : colorMixer(COLORS.accentColor, COLORS.secondColor, percent / 50),
    [durability, percent]
  );

  if (durability) {
    return (
      <div className="durability-bar">
        <div
          style={{
            visibility: percent > 0 ? 'visible' : 'hidden',
            height: '100%',
            width: `${percent}%`,
            backgroundColor: color,
            transition: `background ${0.3}s ease, width ${0.3}s ease`,
          }}
        />
      </div>
    );
  }

  return <WeightBricks percent={percent} />;
};

export default WeightBar;