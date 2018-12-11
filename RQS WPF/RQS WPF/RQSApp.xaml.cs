using System;
using System.Collections.Generic;
using System.Linq;
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
using System.Net;
using System.IO;
using System.Runtime.Serialization.Json;
using System.Net.Http;
using Newtonsoft.Json;

namespace RQS_WPF
{
    /// <summary>
    /// Logique d'interaction pour RQSApp.xaml
    /// </summary>
    public partial class RQSApp : Window
    {
        private List<Film> films;
        private SimpleFilm film;
        private Review review;
        private String URL = "http://localhost:9082/ords/cc/";
        private String username = "Dummy";
        public RQSApp()
        {
            InitializeComponent();

            GreetingsTB.Text = "Bonjour " + username + " !";
        }

        public RQSApp(String user = "Dummy")
        {
            InitializeComponent();

            username = user;

            GreetingsTB.Text = "Bonjour " + username + " !";
        }

        void getFilmByCritere(String senddata, int centrale = 1)
        {
            var request = (HttpWebRequest)WebRequest.Create(URL + "RechercheCC.SearchFilm");

            var data = Encoding.ASCII.GetBytes("arg=" + senddata + "&recurs=" + centrale);

            request.Method = "POST";
            request.Timeout = 200000; // Histoire de ne pas être sur le fil du timeout lors d'une longue recherche..
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = data.Length;
            try
            {
                using (var stream = request.GetRequestStream())
                {
                    stream.Write(data, 0, data.Length);
                }
            
                var response = (HttpWebResponse)request.GetResponse();

                var json = new StreamReader(response.GetResponseStream()).ReadToEnd();

                json = json.Substring(1, json.Length - 3); // Virer les accolades en trop..

                films = JsonConvert.DeserializeObject<List<Film>>(json);
            }
            catch (WebException e)
            {
                if(e.Status == WebExceptionStatus.Timeout)
                    MessageBox.Show("Le serveur prends trop de temps à répondre.", "Time out !", MessageBoxButton.OK, MessageBoxImage.Error);
                else
                    MessageBox.Show("Une erreur est survenue: " + e.Message , "Erreur !", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            
        }

        void getFilmById(int senddata)
        {
            var request = (HttpWebRequest)WebRequest.Create(URL + "RechercheCC.GetFilmById?numero=" + senddata);

            var response = (HttpWebResponse)request.GetResponse();

            String json = new StreamReader(response.GetResponseStream()).ReadToEnd();

            film = JsonConvert.DeserializeObject<SimpleFilm>(json);
        }


        private int SendVoteGet(int idfilm, String login, int cote, String avis)
        {
            var request = (HttpWebRequest)WebRequest.Create(URL + "RechercheCC.Voter?username=" + login + "&idmovie=" + idfilm.ToString() + "&note=" + cote + "&commentaire=" + avis);

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

        void getVote(int idfilm, String login)
        {
            var request = (HttpWebRequest)WebRequest.Create(URL + "RechercheCC.GetVote");

            var data = Encoding.ASCII.GetBytes("username=" + login + "&idmovie=" + idfilm.ToString());

            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = data.Length;
           
            using (var stream = request.GetRequestStream())
            {
                stream.Write(data, 0, data.Length);
            }

            var response = (HttpWebResponse)request.GetResponse();

            var json = new StreamReader(response.GetResponseStream()).ReadToEnd();
            

            review = JsonConvert.DeserializeObject<Review>(json);
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        protected override void OnMouseLeftButtonDown(MouseButtonEventArgs e)
        {
            base.OnMouseLeftButtonDown(e);
            try
            {
                this.DragMove();
            }
            catch (Exception)
            { }
        }

        private void RechercheButton_Click(object sender, RoutedEventArgs e)
        {
            DateTime date;
            films = null;
            film = null;
            if (FilmIdBR.IsChecked == true)
            {
                try
                {
                    getFilmById(int.Parse(RechercherTB.Text));
                    NotFoundLabel.Visibility = Visibility.Hidden;
                    if (film != null)
                    {
                        TitleSimpleTB.Text = film.title;
                        OriginalTitleSimpleTB.Text = film.original_title;
                        StatusSimpleTB.Text = film.status;
                        ReleaseDateSimpleTB.Text = film.release_date;
                        SimpleDisplayCanvas.Visibility = Visibility.Visible;
                    }
                }
                catch(ArgumentException)
                {
                    MessageBox.Show("Vous devez entrer un numéro.", "Id de film invalide !", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                catch (FormatException)
                {
                    MessageBox.Show("Vous devez entrer un numéro.", "Id de film invalide !", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                catch (Exception)
                {
                    NotFoundLabel.Visibility = Visibility.Visible;
                    SimpleDisplayCanvas.Visibility = Visibility.Hidden;
                }
                return;
            }
            else if (FilmBR.IsChecked == true)
            {
                getFilmByCritere("TITLE=[" + RechercherTB.Text + "]");
            }
            else if (ActeurBR.IsChecked == true)
            {
                getFilmByCritere("ACTORS=[" + RechercherTB.Text + "]");
            }
            else if (DirectorBR.IsChecked == true)
            {
                getFilmByCritere("DIRECTORS=[" + RechercherTB.Text + "]");
            }
            else if (DateBR.IsChecked == true)
            {
                
                if (DateTime.TryParse(RechercherTB.Text, out date))
                {
                    if (EqualsDateBR.IsChecked == true)
                        getFilmByCritere("DATE=[eq" + String.Format("{0:d/MM/yyyy}", date) + "]");
                    else if (InfDateBR.IsChecked == true)
                        getFilmByCritere("DATE=[in" + String.Format("{0:d/MM/yyyy}", date) + "]");
                    else if (SupDateBR.IsChecked == true)
                        getFilmByCritere("DATE=[su" + String.Format("{0:d/MM/yyyy}", date) + "]");
                }
                else
                {
                    MessageBox.Show("Le champ doit être au format date (exemple: DD-MM-YYYY).", "Date invalide !", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else if (OthersBR.IsChecked == true)
            {
                String to_send = "";
                int centrale = (!PersoSurCentraleCB.IsChecked.Value) ? 1 : 0;

                if (PersoDateTB.Text.Length > 0)
                {
                    if (!DateTime.TryParse(PersoDateTB.Text, out date))
                    {
                        MessageBox.Show("Le champ Date doit être au format date (exemple: DD-MM-YYYY).", "Date invalide !", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }

                    if (PersoDateEqRadio.IsChecked == true)
                    {
                        to_send += "DATE=[eq" + PersoDateTB.Text;
                    }
                    else if (PersoDateInRadio.IsChecked == true)
                    {
                        to_send += "DATE=[in" + PersoDateTB.Text;
                    }
                    else if (PersoDateSuRadio.IsChecked == true)
                    {
                        to_send += "DATE=[su" + PersoDateTB.Text;
                    }
                }

                if(PersoTitleTB.Text.Length > 0)
                {
                    if (to_send.Length > 0)
                        to_send += "]";
                    to_send += "TITLE=[" + PersoTitleTB.Text;
                }
                if (PersoActorsTB.Text.Length > 0)
                {
                    if (to_send.Length > 0)
                        to_send += "]";
                    to_send += "ACTORS=[" + PersoActorsTB.Text;
                }
                if (PersoDirectorsTB.Text.Length > 0)
                {
                    if (to_send.Length > 0)
                        to_send += "]";
                    to_send += "DIRECTORS=[" + PersoDirectorsTB.Text;
                }

                if (to_send.Length > 0)
                    to_send += "]";

                getFilmByCritere(to_send, centrale);
                
            }


            if (films == null || films.Count == 0)
            {
                MessageBox.Show("L'élément \"" + RechercherTB.Text + "\" ne se trouves pas dans la base de données !", "Rien n'a été trouvé !", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            else
            {
                PageMinTB.Text = "1";
                PageMaxTB.Text = films.Count.ToString();

                FilmTitleTB.Text = films.ElementAt(0).title;

                PreviewButton.Visibility = Visibility.Hidden;

                InfosFilmCanvas.Visibility = Visibility.Visible;

                if (films.Count > 1)
                {
                    NextButton.Visibility = Visibility.Visible;
                }

                RefreshFilm(0);

            }

            

        }

        private void RefreshFilm(int arg)
        {

            FilmTitleTB.Text = films.ElementAt(arg).title;
            FilmOriginalTitleTB.Text = films.ElementAt(arg).original_title;
            FilmStatusTB.Text = films.ElementAt(arg).status.ElementAt(0).name;
            FilmReleaseDateTB.Text = films.ElementAt(arg).release_date;
            FilmVoteAverageTB.Text = films.ElementAt(arg).vote_average.ToString();
            FilmVoteCountTB.Text = films.ElementAt(arg).vote_count.ToString();
            if (films.ElementAt(arg).certifications != null)
            {
                FilmCertificationTB.Text = films.ElementAt(arg).certifications.ElementAt(0).name;
                FilmCertificationDescriptionTB.Text = films.ElementAt(arg).certifications.ElementAt(0).description.Replace(". ", ".\n");
            }
            else
            {
                FilmCertificationTB.Text = "none";
                FilmCertificationDescriptionTB.Text = "";
            }
            FilmRuntimeTB.Text = films.ElementAt(arg).runtime.ToString() + " min";

            byte[] poster = films.ElementAt(arg).poster;
            
            if (poster != null)
            {
                MemoryStream ms = new MemoryStream(poster);

                BitmapImage img = new BitmapImage();
                img.BeginInit();
                img.StreamSource = ms;
                img.EndInit();

                PosterImage.Source = img;
            }
            else
            {
                PosterImage.Source = new BitmapImage(new Uri(@"http://laofcs.org/wp-content/uploads/2017/07/Film.png"));
            }

            GenreTB.Text = "";

            foreach (Genre g in films.ElementAt(arg).genres)
            {
                GenreTB.Text += g.name + " ;";
            }
        }

        private void CroixButton_MouseDown(object sender, MouseButtonEventArgs e)
        {
            InfosFilmCanvas.Visibility = Visibility.Hidden;
        }

        private void NextButton_Click(object sender, RoutedEventArgs e)
        {
            if (int.Parse(PageMinTB.Text) < int.Parse(PageMaxTB.Text))
            {
                PageMinTB.Text = (int.Parse(PageMinTB.Text) + 1).ToString();

                PreviewButton.Visibility = Visibility.Visible;

                if (int.Parse(PageMinTB.Text) == int.Parse(PageMaxTB.Text))
                {
                    NextButton.Visibility = Visibility.Hidden;
                }


                RefreshFilm(int.Parse(PageMinTB.Text) - 1);
            }
        }

        private void PreviewButton_Click(object sender, RoutedEventArgs e)
        {
            if (int.Parse(PageMinTB.Text) > 1)
            {
                PageMinTB.Text = (int.Parse(PageMinTB.Text) - 1).ToString();

                NextButton.Visibility = Visibility.Visible;

                if (int.Parse(PageMinTB.Text) == 1)
                {
                    PreviewButton.Visibility = Visibility.Hidden;
                }



                RefreshFilm(int.Parse(PageMinTB.Text) - 1);
            }
        }

        private void VoteButton_MouseDown(object sender, MouseButtonEventArgs e)
        {
            VoteCanvas.Visibility = Visibility.Visible;

            TitleFilmAvisTB.Text = FilmTitleTB.Text;

            review = null;
            try
            {
                getVote(films.ElementAt(int.Parse(PageMinTB.Text) - 1).id, username);
            }
            catch(Exception)
            {
                CoteSlider.Value = 0;
                AvisTB.Text = null;
            }

            if(review != null)
            {
                CoteSlider.Value = review.cote;
                AvisTB.Text = review.avis;
            }
        }

        private void CoteSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            ValueSlider.Text = Math.Round(CoteSlider.Value).ToString();
        }

        private void CancelVoteButton_Click(object sender, RoutedEventArgs e)
        {
            VoteCanvas.Visibility = Visibility.Hidden;

            AvisTB.Text = "";
            CoteSlider.Value = 0;
        }

        private void SendVoteButton_Click(object sender, RoutedEventArgs e)
        {
            int retour = SendVoteGet(films.ElementAt(int.Parse(PageMinTB.Text) - 1).id, username, int.Parse(ValueSlider.Text), AvisTB.Text);

            if(retour == 1)
            {
                MessageBox.Show("Vous avez voté pour le film " + FilmTitleTB.Text + " avec succès !", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                RechercheButton_Click(this, null);
                VoteCanvas.Visibility = Visibility.Hidden;
            }
            else
            {
                MessageBox.Show("Recommencez ultérieurement", "Une erreur est survenue !", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            
            AvisTB.Text = "";
            CoteSlider.Value = 0;
        }

        private void InfoProdButton_Click(object sender, RoutedEventArgs e)
        {
            InfoProdCanvas.Visibility = Visibility.Visible;

            List<String> directorsNames = new List<string>();
            List<String> actorsNames = new List<string>();


            foreach (Realisateur d in films.ElementAt(int.Parse(PageMinTB.Text) - 1).realisateurs)
            {
                directorsNames.Add(d.name);
            }

            foreach (Acteur a in films.ElementAt(int.Parse(PageMinTB.Text) - 1).acteurs)
            {
                actorsNames.Add(a.name);
            }

            DirectorsLB.ItemsSource = directorsNames;
            ActorsLB.ItemsSource = actorsNames;


        }

        private void CloseInfoProdButton_Click(object sender, RoutedEventArgs e)
        {
            InfoProdCanvas.Visibility = Visibility.Hidden;
        }

        private void DeleteVoteButton_Click(object sender, RoutedEventArgs e)
        {

            int retour = SendVoteGet(films.ElementAt(int.Parse(PageMinTB.Text) - 1).id, username, -1, AvisTB.Text); // La cote est négative -> on supprime

            if (retour == 1)
            {
                MessageBox.Show("Votre vote a été supprimé avec succès !", "Vote supprimé !", MessageBoxButton.OK, MessageBoxImage.Information);

                RechercheButton_Click(this, null);
                VoteCanvas.Visibility = Visibility.Hidden;
            }
            else
            {
                MessageBox.Show("Recommencez ultérieurement", "Une erreur est survenue !", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void DateBR_Checked(object sender, RoutedEventArgs e)
        {
            DateGroupRadio.Visibility = Visibility.Visible;
        }

        private void DateBR_Unchecked(object sender, RoutedEventArgs e)
        {
            DateGroupRadio.Visibility = Visibility.Hidden;
        }

        private void FilmIdBR_Unchecked(object sender, RoutedEventArgs e)
        {
            SimpleDisplayCanvas.Visibility = Visibility.Hidden;
            NotFoundLabel.Visibility = Visibility.Hidden;
        }

        private void OthersBR_Checked(object sender, RoutedEventArgs e)
        {
            RecherchePersoCanvas.Visibility = Visibility.Visible;
            RechercherTB.Text = "< Recherche Perso >";
            RechercherTB.IsEnabled = false;
        }

        private void OthersBR_Unchecked(object sender, RoutedEventArgs e)
        {
            RecherchePersoCanvas.Visibility = Visibility.Hidden;
            RechercherTB.Text = "";
            RechercherTB.IsEnabled = true;
        }
    }
}
