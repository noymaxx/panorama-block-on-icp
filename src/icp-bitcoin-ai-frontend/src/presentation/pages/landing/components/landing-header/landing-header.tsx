import React, { useState } from "react";
import styles from "./landing-header-styles.module.scss";
import Button from "../../../../components/button/button";
import { useNavigate } from "react-router-dom";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent"
// import { HttpAgent } from "@dfinity/agent";
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
];

const LandingHeader: React.FC = () => {
  const [active, setActive] = useState(0);
  const navigate = useNavigate();

  // Função para conectar com o Internet Identity
  const handleConnectWallet = async () => {
    const authClient = await AuthClient.create();

    await authClient.login({
      identityProvider: import.meta.env.II_CANISTER_ID, // Certifique-se de definir esta variável de ambiente
      onSuccess: async () => {
        console.log("menos mal");
        const identity = authClient.getIdentity();
        console.log("oie: ", identity)
        const agent = new HttpAgent({ identity });
        console.log("o tal do polling: ", agent)
        const actor = createActor(import.meta.env.VITE_MEMPOOL_CANISTER_ID, {
          agent,
        });
        // Aqui você pode armazenar o ator no estado global ou contexto, se precisar usar em outras partes do app
        console.log("Logged in with Identity:", identity);
        navigate("/home");
      },
    });
  };

  return (
    <div className={styles.header}>
      <img className={styles.logo} src="/Logo.png" alt="" />
      <nav className={styles.navigation}>
        {navItems.map((item, index) => (
          <div
            key={index}
            className={`${styles.navItem} ${
              active === index ? styles.active : ""
            }`}
            onClick={() => {
              setActive(index);
              index === 1 && window.scrollTo({ top: 600, behavior: "smooth" });
            }}
          >
            {item.title}
          </div>
        ))}
      </nav>
      <div className={styles.connect}>
        <Button
          type="wallet"
          title="Connect Wallet"
          onClick={handleConnectWallet}
        />
      </div>
    </div>
  );
};

export default LandingHeader;
