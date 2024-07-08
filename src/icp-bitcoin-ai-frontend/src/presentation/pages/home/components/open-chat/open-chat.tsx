import React, { useEffect, useRef, useState } from 'react'
import styles from './open-chat-styles.module.scss'
import { initialise } from "@open-ic/openchat-xframe"
import { OpenChatXFrame } from "@open-ic/openchat-xframe/lib/types"

const purple = "rgb(182, 95, 247)"
const txt = "#ffffff"
const txtLight = "#efefef"
const background = "#242424"

function initialiseOpenChatFrame(
  path: string,
  iframe: HTMLIFrameElement
): Promise<OpenChatXFrame> {
  return initialise(iframe, {
    targetOrigin: "https://oc.app",
    initialPath: '/community/rfeib-riaaa-aaaar-ar3oq-cai/channel/334961401678552956581044255076222828441',
    settings: {
      disableLeftNav: true
    },
    theme: {
      name: "vaultbet",
      base: "dark",
      overrides: {
        burst: false,
        primary: purple,
        bd: purple,
        bg: background,
        txt: txt,
        placeholder: txtLight,
        "txt-light": txtLight,
        timeline: {
          txt: txt,
        },
        time: {
          txt: txt,
          icon: txt,
        },
        menu: {
          bd: purple,
          separator: purple,
        },
        scrollbar: {
          bg: purple,
        },
        button: {
          bg: purple,
          hv: purple,
        },
        icon: {
          txt: txtLight,
        },
        currentChat: {
          date: {
            bd: `solid 1px ${purple}`,
            bg: "rgba(0,0,0,0.8)",
            txt: txtLight,
          },
          msg: {
            bd: `solid 1px ${purple}`,
            me: {
              bg: purple,
              txt: "#fff",
            },
            txt: txt,
          },
        },
      },
    },
  })
}

type Props = {
  path: string
  title: string
}

const OpenChat: React.FC = () => {
  const iframe = useRef<HTMLIFrameElement>(null)
  const path = "/community/dgegb-daaaa-aaaar-arlhq-cai/channel/12148470416168947889486180374669069959"
  const title = "Announcements"

  const [client, setClient] = useState<Promise<OpenChatXFrame> | undefined>(
    undefined
  )

  useEffect(() => {
    if (iframe.current) {
      if (client === undefined) {
        setClient(initialiseOpenChatFrame(path, iframe.current))
      }
    }
  }, [client])

  return (
    <div className={styles.openChat}>
      <iframe ref={iframe} title="OpenChat" frameBorder="0" />
    </div>
  )
}

export default OpenChat