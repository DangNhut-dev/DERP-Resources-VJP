import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { Box, createStyles, Group } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import ScaleFade from '../../transitions/ScaleFade';
import remarkGfm from 'remark-gfm';
import type { TextUiPosition, TextUiProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';

const useStyles = createStyles((theme, params: { position?: TextUiPosition }) => ({
  wrapper: {
    height: '100%',
    width: '100%',
    position: 'absolute',
    display: 'flex',
    alignItems:
      params.position === 'top-center' ? 'baseline' :
      params.position === 'bottom-center' ? 'flex-end' : 'center',
    justifyContent:
      params.position === 'right-center' ? 'flex-end' :
      params.position === 'left-center' ? 'flex-start' : 'center',
  },
  container: {
    fontSize: 14,
    padding: '10px 16px',
    margin: 8,
    fontFamily: 'Roboto',
    color: '#FFFFFF',
    borderRadius: 3,
    background: 'linear-gradient(135deg, #0a0a0a 0%, #0d1a1a 60%, rgba(5,242,242,0.12) 100%)',
    border: '1px solid rgba(255,255,255,0.15)',
    borderTop: '1px solid rgba(255,255,255,0.25)',
    borderLeft: '2px solid #05F2F2',
    boxShadow: `
      inset 0 1px 0 rgba(255,255,255,0.06),
      inset 0 -2px 8px rgba(0,0,0,0.5),
      0 4px 16px rgba(0,0,0,0.7),
      0 0 20px rgba(5,242,242,0.06)
    `,
    filter: 'drop-shadow(0 2px 8px rgba(0,0,0,0.6))',
  },
  iconWrapper: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: 28,
    height: 28,
    borderRadius: 3,
    background: 'linear-gradient(135deg, #0d0d0d 0%, rgba(5,242,242,0.18) 100%)',
    border: '1px solid rgba(5,242,242,0.25)',
    boxShadow: '0 0 8px rgba(5,242,242,0.1)',
    flexShrink: 0,
  },
}));

const TextUI: React.FC = () => {
  const [data, setData] = React.useState<TextUiProps>({
    text: '',
    position: 'right-center',
  });
  const [visible, setVisible] = React.useState(false);
  const { classes } = useStyles({ position: data.position });

  useNuiEvent<TextUiProps>('textUi', (data) => {
    if (!data.position) data.position = 'right-center';
    setData(data);
    setVisible(true);
  });

  useNuiEvent('textUiHide', () => setVisible(false));

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible}>
          <Box style={data.style} className={classes.container}>
            <Group spacing={10} noWrap>
              {data.icon && (
                <Box className={classes.iconWrapper}>
                  <LibIcon
                    icon={data.icon}
                    fixedWidth
                    size="sm"
                    animation={data.iconAnimation}
                    style={{
                      color: data.iconColor || '#FFFFFF',
                      alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start',
                    }}
                  />
                </Box>
              )}
              <ReactMarkdown components={MarkdownComponents} remarkPlugins={[remarkGfm]}>
                {data.text}
              </ReactMarkdown>
            </Group>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default TextUI;