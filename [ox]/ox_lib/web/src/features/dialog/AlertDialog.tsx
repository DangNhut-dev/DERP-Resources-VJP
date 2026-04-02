import { Button, createStyles, Group, Modal, Stack, useMantineTheme } from '@mantine/core';
import { useState } from 'react';
import ReactMarkdown from 'react-markdown';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import { useLocales } from '../../providers/LocaleProvider';
import remarkGfm from 'remark-gfm';
import type { AlertProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';

const useStyles = createStyles((theme) => ({
  modalContent: {
    backgroundColor: 'rgba(0, 0, 0, 0.85) !important',
    border: '1px solid rgba(255, 255, 255, 1)',
    borderRadius: theme.radius.sm,
    color: '#FFFFFF',
  },
  modalHeader: {
    backgroundColor: 'transparent !important',
    borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
    paddingBottom: 12,
  },
  modalTitle: {
    color: '#05F2F2 !important',
    fontWeight: 600,
    '& p': {
      color: '#05F2F2 !important',
    },
  },
  modalOverlay: {
    backgroundColor: 'rgba(0, 0, 0, 0.6) !important',
  },
  contentStack: {
    color: 'rgba(255, 255, 255, 0.7)',
    '& p': {
      color: 'rgba(255, 255, 255, 0.7)',
    },
    '& strong': {
      color: '#FFFFFF',
    },
    '& a': {
      color: '#05F2F2',
    },
    '& code': {
      backgroundColor: 'rgba(255, 255, 255, 0.06)',
      border: '1px solid rgba(255, 255, 255, 0.08)',
      color: '#05F2F2',
      padding: '2px 6px',
      borderRadius: 4,
    },
    '& table': {
      borderColor: 'rgba(255, 255, 255, 0.1)',
    },
    '& th, & td': {
      borderColor: 'rgba(255, 255, 255, 0.1)',
      color: 'rgba(255, 255, 255, 0.7)',
    },
    '& th': {
      color: '#05F2F2',
    },
  },
  cancelButton: {
    backgroundColor: 'rgba(255, 255, 255, 0.06) !important',
    border: '1px solid rgba(255, 255, 255, 0.12) !important',
    color: '#FFFFFF !important',
    '&:hover': {
      backgroundColor: 'rgba(255, 255, 255, 0.1) !important',
    },
  },
  confirmButton: {
    backgroundColor: 'rgba(5, 242, 242, 0.15) !important',
    border: '1px solid rgba(5, 242, 242, 0.3) !important',
    color: '#05F2F2 !important',
    '&:hover': {
      backgroundColor: 'rgba(5, 242, 242, 0.25) !important',
    },
  },
  confirmOnlyButton: {
    backgroundColor: 'rgba(255, 255, 255, 0.06) !important',
    border: '1px solid rgba(255, 255, 255, 0.12) !important',
    color: '#FFFFFF !important',
    '&:hover': {
      backgroundColor: 'rgba(255, 255, 255, 0.1) !important',
    },
  },
}));

const AlertDialog: React.FC = () => {
  const { locale } = useLocales();
  const { classes } = useStyles();
  const [opened, setOpened] = useState(false);
  const [dialogData, setDialogData] = useState<AlertProps>({
    header: '',
    content: '',
  });

  const closeAlert = (button: string) => {
    setOpened(false);
    fetchNui('closeAlert', button);
  };

  useNuiEvent('sendAlert', (data: AlertProps) => {
    setDialogData(data);
    setOpened(true);
  });

  useNuiEvent('closeAlertDialog', () => {
    setOpened(false);
  });

  return (
    <>
      <Modal
        opened={opened}
        centered={dialogData.centered}
        size={dialogData.size || 'md'}
        overflow={dialogData.overflow ? 'inside' : 'outside'}
        closeOnClickOutside={false}
        onClose={() => {
          setOpened(false);
          closeAlert('cancel');
        }}
        withCloseButton={false}
        overlayOpacity={0.5}
        exitTransitionDuration={150}
        transition="fade"
        classNames={{
          modal: classes.modalContent,
          header: classes.modalHeader,
          title: classes.modalTitle,
          overlay: classes.modalOverlay,
        }}
        title={<ReactMarkdown components={MarkdownComponents}>{dialogData.header}</ReactMarkdown>}
      >
        <Stack className={classes.contentStack}>
          <ReactMarkdown
            remarkPlugins={[remarkGfm]}
            components={{
              ...MarkdownComponents,
              img: ({ ...props }) => (
                <img
                  style={{
                    maxWidth: '100%',
                    maxHeight: '100%',
                    borderRadius: 4,
                    border: '1px solid rgba(255, 255, 255, 0.08)',
                  }}
                  {...props}
                />
              ),
            }}
          >
            {dialogData.content}
          </ReactMarkdown>
          <Group position="right" spacing={10}>
            {dialogData.cancel && (
              <Button uppercase className={classes.cancelButton} onClick={() => closeAlert('cancel')} mr={3}>
                {dialogData.labels?.cancel || locale.ui.cancel}
              </Button>
            )}
            <Button
              uppercase
              className={dialogData.cancel ? classes.confirmButton : classes.confirmOnlyButton}
              onClick={() => closeAlert('confirm')}
            >
              {dialogData.labels?.confirm || locale.ui.confirm}
            </Button>
          </Group>
        </Stack>
      </Modal>
    </>
  );
};

export default AlertDialog;