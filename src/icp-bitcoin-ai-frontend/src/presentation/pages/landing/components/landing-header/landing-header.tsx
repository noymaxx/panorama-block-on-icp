import React, { useState } from "react";
import styles from "./landing-header-styles.module.scss";
import Button from "../../../../components/button/button";
import { useNavigate } from "react-router-dom";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent"
import { createActor } from "../../../../../../../declarations/mempool";

// const host = "http://localhost:4943/";
// const host = "https://identity.ic0.app";

type Item = {
  title: string;
  url: string;
};

const navItems: Item[] = [
  { title: "Home", url: "/#home" },
  { title: "About", url: "#about" },
  { title: "Docs", url: "https://docs.panoramablock.com/" },
];

const LandingHeader: React.FC = () => {
  const [active, setActive] = useState(0);
  const navigate = useNavigate();

  // Função para conectar com o Internet Identity
  const handleConnectWallet = async () => {
    const authClient = await AuthClient.create();

    await authClient.login({
      identityProvider: import.meta.env.VITE_II_CANISTER_ID, // Certifique-se de definir esta variável de ambiente
      onSuccess: async () => {
        const identity = authClient.getIdentity();
        const agent = new HttpAgent({ identity });
        const actor = createActor(import.meta.env.VITE_MEMPOOL_CANISTER_ID, {
          agent,
        });
        navigate("/home");
      },
    });
  };

  return (
    <div className={styles.header}>
      <div className={styles.container}>
        <img className={styles.logo} src="/Logo.png" alt="" />
        <nav className={styles.navigation}>
          {navItems.map((item, index) => (
            item.title !== "Docs" ? (
              <div
                key={index}
                className={`${styles.navItem} ${active === index ? styles.active : ""
                  }`}
                onClick={() => {
                  setActive(index);
                  index === 1 && window.scrollTo({ top: 1024, behavior: "smooth" });
                }}
              >
                {item.title}
              </div>
            )
              : (
                <a className={`${styles.navItem} ${active === index ? styles.active : ""}`} href={item.url} target="__blank">{item.title}</a>
              )
          ))}
        </nav>
        <div className={styles.connect}>
          <Button
            type="wallet"
            title="Launch App"
            onClick={handleConnectWallet}
          />
        </div>
      </div>
    </div >
  );
};

export default LandingHeader;
