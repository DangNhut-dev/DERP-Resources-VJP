import { Button, createStyles, Group, HoverCard, Image, Progress, Stack, Text } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import { ContextMenuProps, Option } from '../../../../typings';
import { fetchNui } from '../../../../utils/fetchNui';
import { isIconUrl } from '../../../../utils/isIconUrl';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import MarkdownComponents from '../../../../config/MarkdownComponents';
import LibIcon from '../../../../components/LibIcon';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: false });
};

const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const useStyles = createStyles((theme, params: { disabled?: boolean; readOnly?: boolean }) => ({
  inner: {
    justifyContent: 'flex-start',
  },
  label: {
    width: '100%',
    color: params.disabled ? 'rgba(255,255,255,0.2)' : '#FFFFFF',
    whiteSpace: 'pre-wrap',
  },
  button: {
    position: 'relative',
    height: 'fit-content',
    width: '100%',
    padding: 10,
    background: 'linear-gradient(180deg, rgba(24,24,24,0.82) 0%, rgba(15,15,15,0.82) 100%)',
    border: '1px solid rgba(255,255,255,0.07)',
    borderTop: '1px solid rgba(255,255,255,0.12)',
    borderLeft: '2px solid transparent',
    borderRadius: 3,
    boxShadow: `
      inset 0 1px 0 rgba(255,255,255,0.04),
      inset 0 -2px 6px rgba(0,0,0,0.4),
      0 3px 8px rgba(0,0,0,0.5),
      0 1px 2px rgba(0,0,0,0.8)
    `,
    transition: 'all 0.15s ease',
    '&:hover': {
      background: params.readOnly
        ? 'linear-gradient(180deg, rgba(24,24,24,0.82) 0%, rgba(15,15,15,0.82) 100%)'
        : 'linear-gradient(180deg, rgba(26,36,36,0.88) 0%, rgba(16,24,24,0.88) 100%)',
      borderColor: params.readOnly ? 'rgba(255,255,255,0.07)' : 'rgba(5,242,242,0.2)',
      borderLeftColor: params.readOnly ? 'transparent' : '#05F2F2',
      transform: params.readOnly ? 'unset' : 'translateX(2px)',
      boxShadow: params.readOnly
        ? 'inset 0 1px 0 rgba(255,255,255,0.04), inset 0 -2px 6px rgba(0,0,0,0.4), 0 3px 8px rgba(0,0,0,0.5)'
        : 'inset 0 1px 0 rgba(5,242,242,0.05), inset 0 -2px 6px rgba(0,0,0,0.4), 0 3px 12px rgba(0,0,0,0.6), 0 0 10px rgba(5,242,242,0.07)',
    },
    '&:active': {
      transform: params.readOnly ? 'unset' : 'translateX(2px)',
    },
    '&:disabled': {
      background: 'linear-gradient(180deg, rgba(17,17,17,0.75) 0%, rgba(10,10,10,0.75) 100%)',
      borderColor: 'rgba(255,255,255,0.04)',
      borderLeftColor: 'transparent',
      boxShadow: 'none',
    },
  },
  iconImage: {
    maxWidth: '25px',
  },
  description: {
    color: params.disabled ? 'rgba(255,255,255,0.15)' : 'rgba(255,255,255,0.45)',
    fontSize: 12,
  },
  dropdown: {
    padding: 10,
    background: 'linear-gradient(180deg, #1a1a1a 0%, #0e0e0e 100%)',
    border: '1px solid rgba(255,255,255,0.1)',
    borderTop: '2px solid #05F2F2',
    boxShadow: '0 8px 24px rgba(0,0,0,0.8)',
    color: 'rgba(255,255,255,0.7)',
    fontSize: 14,
    maxWidth: 256,
    width: 'fit-content',
  },
  buttonStack: {
    gap: 4,
    flex: '1',
  },
  buttonGroup: {
    gap: 6,
    flexWrap: 'nowrap',
  },
  buttonIconContainer: {
    width: 25,
    height: 25,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonTitleText: {
    overflowWrap: 'break-word',
    color: '#FFFFFF',
    fontSize: 13,
    fontWeight: 500,
  },
  buttonArrowContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    width: 25,
    height: 25,
  },
  arrow: {
    color: 'rgba(5,242,242,0.4)',
  },
  metadataLabel: {
    color: '#05F2F2',
  },
  metadataValue: {
    color: 'rgba(255,255,255,0.6)',
  },
}));

const ContextButton: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  const button = option[1];
  const buttonKey = option[0];
  const { classes } = useStyles({ disabled: button.disabled, readOnly: button.readOnly });

  return (
    <>
      <HoverCard
        position="right-start"
        disabled={button.disabled || !(button.metadata || button.image)}
        openDelay={200}
      >
        <HoverCard.Target>
          <Button
            classNames={{ inner: classes.inner, label: classes.label, root: classes.button }}
            onClick={() =>
              !button.disabled && !button.readOnly
                ? button.menu
                  ? openMenu(button.menu)
                  : clickContext(buttonKey)
                : null
            }
            variant="default"
            disabled={button.disabled}
          >
            <Group position="apart" w="100%" noWrap>
              <Stack className={classes.buttonStack}>
                {(button.title || Number.isNaN(+buttonKey)) && (
                  <Group className={classes.buttonGroup}>
                    {button?.icon && (
                      <Stack className={classes.buttonIconContainer}>
                        {typeof button.icon === 'string' && isIconUrl(button.icon) ? (
                          <img src={button.icon} className={classes.iconImage} alt="Missing img" />
                        ) : (
                          <LibIcon
                            icon={button.icon as IconProp}
                            fixedWidth
                            size="lg"
                            style={{ color: button.iconColor || '#05F2F2' }}
                            animation={button.iconAnimation}
                          />
                        )}
                      </Stack>
                    )}
                    <Text className={classes.buttonTitleText}>
                      <ReactMarkdown components={MarkdownComponents}>{button.title || buttonKey}</ReactMarkdown>
                    </Text>
                  </Group>
                )}
                {button.description && (
                  <Text className={classes.description}>
                    <ReactMarkdown components={MarkdownComponents}>{button.description}</ReactMarkdown>
                  </Text>
                )}
                {button.progress !== undefined && (
                  <Progress
                    value={button.progress}
                    size="sm"
                    color={button.colorScheme || 'cyan'}
                    styles={{
                      root: { backgroundColor: 'rgba(255,255,255,0.06)' },
                    }}
                  />
                )}
              </Stack>
              {(button.menu || button.arrow) && button.arrow !== false && (
                <Stack className={classes.buttonArrowContainer}>
                  <LibIcon icon="chevron-right" fixedWidth className={classes.arrow} />
                </Stack>
              )}
            </Group>
          </Button>
        </HoverCard.Target>
        <HoverCard.Dropdown className={classes.dropdown}>
          {button.image && (
            <Image
              src={button.image}
              styles={{
                image: { borderRadius: 3, border: '1px solid rgba(255,255,255,0.08)' },
              }}
            />
          )}
          {Array.isArray(button.metadata) ? (
            button.metadata.map(
              (
                metadata: string | { label: string; value?: any; progress?: number; colorScheme?: string },
                index: number
              ) => (
                <>
                  <Text key={`context-metadata-${index}`}>
                    {typeof metadata === 'string' ? (
                      <span className={classes.metadataValue}>{metadata}</span>
                    ) : (
                      <>
                        <span className={classes.metadataLabel}>{metadata.label}: </span>
                        <span className={classes.metadataValue}>{metadata?.value ?? ''}</span>
                      </>
                    )}
                  </Text>
                  {typeof metadata === 'object' && metadata.progress !== undefined && (
                    <Progress
                      value={metadata.progress}
                      size="sm"
                      color={metadata.colorScheme || button.colorScheme || 'cyan'}
                      styles={{
                        root: { backgroundColor: 'rgba(255,255,255,0.06)' },
                      }}
                    />
                  )}
                </>
              )
            )
          ) : (
            <>
              {typeof button.metadata === 'object' &&
                Object.entries(button.metadata).map((metadata: { [key: string]: any }, index) => (
                  <Text key={`context-metadata-${index}`}>
                    <span className={classes.metadataLabel}>{metadata[0]}: </span>
                    <span className={classes.metadataValue}>{metadata[1]}</span>
                  </Text>
                ))}
            </>
          )}
        </HoverCard.Dropdown>
      </HoverCard>
    </>
  );
};

export default ContextButton;