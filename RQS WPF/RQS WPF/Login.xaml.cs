using RQS_WPF;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace RQSClient
{
    /// <summary>
    /// Logique d'interaction pour Login.xaml
    /// </summary>
    public partial class Login : Window
    {
        private String URL = "http://localhost:9082/ords/cc/";
        public Login()
        {
            InitializeComponent();

            LoginTB.Focus();
        }

        
        private void QuitterButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        private void LoginButton_Click(object sender, RoutedEventArgs e)
        {
            int ret = SendAuthenticationGet(LoginTB.Text, PasswordTB.Password);
            if (ret == 1)
            {
                RQSApp win = new RQSApp(LoginTB.Text);
                Visibility = Visibility.Hidden;
                win.ShowDialog();
                Visibility = Visibility.Visible;
                LoginTB.Clear();
                PasswordTB.Clear();
                LoginTB.Focus();
            }
            else if(ret == 0)
            {
                MessageBox.Show("Vérifiez d'avoir les bons identifiants ou inscrivez-vous !", "Mot de passe incorrect", MessageBoxButton.OK, MessageBoxImage.Exclamation);
            }
            else
            {
                MessageBox.Show("Une problème est survenu !", "ERROR",MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void InscriptionButton_Click(object sender, RoutedEventArgs e)
        {
            RegisterCanvas.Visibility = Visibility.Visible;
            
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            RegisterCanvas.Visibility = Visibility.Hidden;
        }

        private void ValiderButton_Click(object sender, RoutedEventArgs e)
        {

            int ret = SendRegisterGet(LoginRegTB.Text, PasswordRegTB.Password, NameTB.Text, SurnameTB.Text);
            if (ret == 1)
            {
                MessageBox.Show("Compte créé avec succès !", "Success !", MessageBoxButton.OK, MessageBoxImage.Asterisk);
                RegisterCanvas.Visibility = Visibility.Hidden;
            }
            else if (ret == 0)
            {
                MessageBox.Show("Une erreur est survenue, username déjà existant?", "Erreur lors de l'enregistrement !", MessageBoxButton.OK, MessageBoxImage.Exclamation);
            }
            else
            {
                MessageBox.Show("Une problème est survenu !", "ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        protected override void OnMouseLeftButtonDown(MouseButtonEventArgs e)
        {
            base.OnMouseLeftButtonDown(e);
            
            this.DragMove();
        }

        private int SendAuthenticationGet(String login, String password)
        {
            var request = (HttpWebRequest)WebRequest.Create(URL + "RechercheCC.Authentication?arglogin=" + login + "&passwd=" + password);

            try
            {
                var response = (HttpWebResponse)request.GetResponse();

                return 1;
            }
            catch (System.Net.WebException e)
            {
                if (((HttpWebResponse)e.Response).StatusCode == HttpStatusCode.Forbidden)
                    return 0;
                else
                    return -1;
            }
            
        }

        private int SendRegisterGet(String login, String password, String nom, String prenom)
        {
            var request = (HttpWebRequest)WebRequest.Create(URL + "RechercheCC.Register?argnom=" + nom + "&argprenom=" + prenom + "&arglogin=" + login + "&argpasswd=" + password);

            try
            {
                var response = (HttpWebResponse)request.GetResponse();

                return 1;
            }
            catch (System.Net.WebException e)
            {
                if (((HttpWebResponse)e.Response).StatusCode == HttpStatusCode.Forbidden)
                    return 0;
                else
                    return -1;
            }

        }
    }
}
